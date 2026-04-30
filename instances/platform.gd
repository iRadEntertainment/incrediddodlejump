class_name Platform
extends Node2D


@onready var coll: CollisionShape2D = %coll
@onready var tiles: Node2D = %tiles
@onready var tiles_standard: TileMapLayer = %tiles_standard
@onready var tiles_breakable: TileMapLayer = %tiles_breakable
@onready var tiles_movable: TileMapLayer = %tiles_movable
@onready var tiles_disappear: TileMapLayer = %tiles_disappear
@onready var sfx_break: AudioStreamPlayer = %sfx_break

const GRACE_HEIGHT: float = 128.0 #px

var _despawn_height: float # positive on the -y axis
var is_moving: bool
var is_breakable: bool # if not it is solid
var is_disappear: bool
var has_spring: bool
var has_boost: bool

var velocity: Vector2
var _speed: float = 128.0 #px/s
var _half_size: float
var _despawn_height: float # positive on the -y axis
var _dir_x: int = 1
var _is_activated: bool


func _ready() -> void:
	_despawn_height = -position.y + GRACE_HEIGHT
	_half_size = abs(coll.shape.b.x)
	
	var safe_pos_x: float = Mng.viewport_half_size.x - _half_size
	position.x = clamp(position.x, -safe_pos_x, safe_pos_x)
	
	Mng.game.status_updated.connect(_on_game_status_updated)
	if is_moving:
		_dir_x = 1 if Mng.rng.randf() > 0.5 else -1
	_on_game_status_updated(Mng.game.status)
	
	if has_spring:
		var spring: Spring = preload("uid://bnm2aowmnwtdk").instantiate()
		spring.position.x = Mng.rng.randf_range(-0.5, 0.5) * _half_size
		add_child(spring)
	
	match_texture()


func match_texture() -> void:
	tiles_standard.hide()
	tiles_breakable.hide()
	tiles_movable.hide()
	tiles_disappear.hide()
	if is_breakable: tiles_breakable.show()
	elif is_disappear: tiles_disappear.show()
	elif is_moving: tiles_movable.show()
	else: tiles_standard.show()


func activate() -> void:
	if _is_activated:
		return
	_is_activated = true
	
	var tw: Tween = create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	if is_breakable:
		coll.set_deferred(&"disabled", true)
		sfx_break.play()
		tw.tween_property(tiles_breakable, ^"modulate:a", 0.0, 0.6)
		tw.tween_callback(queue_free).set_delay(1.0)
	else:
		tw.tween_property(self, ^"position:y", 16.0, 0.2).as_relative().set_ease(Tween.EASE_OUT)
		tw.tween_property(self, ^"position:y", 0.0, 0.2).as_relative().set_ease(Tween.EASE_IN)


func _process(_delta: float) -> void:
	if Mng.cam.bottom_height > _despawn_height:
		queue_free()


func _physics_process(delta: float) -> void:
	velocity.x = _speed * _dir_x
	position += velocity * delta
	
	if position.x + _half_size > Mng.viewport_half_size.x: _dir_x = -1
	elif position.x - _half_size < -Mng.viewport_half_size.x: _dir_x = 1


func _on_game_status_updated(game_status: Game.Status) -> void:
	set_process(game_status == Game.Status.RUNNING)
	set_physics_process(game_status == Game.Status.RUNNING and is_moving)
