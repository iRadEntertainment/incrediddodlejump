extends Node2D

@onready var sprite: Sprite2D = %sprite
@onready var sfx_jump: AudioStreamPlayer = %sfx_jump

var _jump_force: float = 900.0 #px
var _g: float = 980.0 #px
var _velocity: Vector2
var _next_rand_pos: Vector2

var _start_y: float

var _dir_x: int = 1:
	set(value):
		if _dir_x == value:
			return
		_dir_x = value
		if is_node_ready():
			sprite.scale.x = _dir_x


func _ready() -> void:
	_start_y = position.y
	set_process(false)
	_pick_next_random_jump()


func _process(delta: float) -> void:
	_velocity.y += _g * delta
	position += _velocity * delta
	
	if position.y > _start_y:
		position.y = _start_y
		set_process(false)
		_pick_next_random_jump()


func _pick_next_random_jump() -> void:
	var rand_x: float = randf() * Mng.viewport_size.x
	_next_rand_pos = Vector2(rand_x, _start_y)
	_dir_x = 1 if rand_x > position.x else -1
	
	await get_tree().create_timer(randf_range(0.5, 2.5)).timeout
	_jump_to_next()


func _jump_to_next() -> void:
	sfx_jump.play()
	_velocity.x = (_next_rand_pos.x - position.x) * 0.5
	_velocity.y = -_jump_force
	set_process(true)
