class_name Platform
extends Node2D


@onready var coll: CollisionShape2D = %coll

const GRACE_HEIGHT: float = 128.0 #px

var _despawn_height: float # positive on the -y axis
var is_moving: bool
var has_spring: bool

var velocity: Vector2
var _speed: float = 128.0 #px/s
var _half_size: float
var _dir_x: int = 1


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
