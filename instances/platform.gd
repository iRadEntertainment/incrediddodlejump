class_name Platform
extends StaticBody2D

enum Type {
	STANDARD,
	BREAKABLE,
	MOVING,
	DISAPPEAR,
}

@onready var coll: CollisionShape2D = %coll
@onready var tiles: TileMapLayer = %tiles
@onready var sfx_break: AudioStreamPlayer = %sfx_break

const GRACE_HEIGHT: float = 128.0 #px
const TILES_BY_TYPE: Dictionary[Type, Array] = {
	Type.STANDARD: [Vector2i(3, 10), Vector2i(2, 10), Vector2i(4, 10)],
	Type.BREAKABLE: [Vector2i(8, 11), Vector2i(9, 11), Vector2i(10, 11)],
	Type.MOVING: [Vector2i(16, 9), Vector2i(17, 9), Vector2i(0, 10)],
	Type.DISAPPEAR: [Vector2i(10, 14), Vector2i(11, 14), Vector2i(12, 14)],
}

var is_moving: bool
var is_breakable: bool # if not it is solid
var is_disappear: bool
var is_long: bool
var has_spring: bool
var has_boost: bool

var _type: Type:
	get: return _get_type()
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
	
	_update_tiles()


func _get_type() -> Type:
	if is_breakable: return Type.BREAKABLE
	elif is_disappear: return Type.DISAPPEAR
	elif is_moving: return Type.MOVING
	return Type.STANDARD


func _update_tiles() -> void:
	var tile_coord: Array = TILES_BY_TYPE[_type]
	var start_tile: Vector2i = tile_coord[0]
	var mid_tile: Vector2i = tile_coord[1]
	var end_tile: Vector2i = tile_coord[2]
	
	var half_length: int = 3 if is_long else 2
	var tiles_range: Array = range(-half_length, half_length)
	
	for i: int in tiles_range.size():
		var x: int = tiles_range[i]
		var coords: Vector2i = Vector2i(x, 0)
		if i == 0:
			tiles.set_cell(coords, 0, start_tile)
		elif i == tiles_range.size() - 1:
			tiles.set_cell(coords, 0, end_tile)
		else:
			tiles.set_cell(coords, 0, mid_tile)


func activate() -> void:
	if _is_activated:
		return
	_is_activated = true
	
	var tw: Tween = create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	if is_breakable:
		coll.set_deferred(&"disabled", true)
		sfx_break.play()
		tw.tween_property(tiles, ^"modulate:a", 0.0, 0.6)
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
