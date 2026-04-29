class_name GameCamera
extends Camera2D

@export var follow_speed: float = 2.0

var _head_space: float
var _target_height: float:
	get: return (Mng.player.position.y - _head_space)

var top_height: float:
	get: return -get_screen_center_position().y + Mng.viewport_half_size.y
var bottom_height: float:
	get: return -get_screen_center_position().y - Mng.viewport_half_size.y

func _init() -> void:
	Mng.cam = self


func _ready() -> void:
	position.x = 0
	position.y = _target_height
	@warning_ignore_start("narrowing_conversion")
	limit_left = -Mng.viewport_half_size.x
	limit_right = Mng.viewport_half_size.x
	@warning_ignore_restore("narrowing_conversion")
	
	_head_space = Mng.viewport_size.y * 0.25


func _process(delta: float) -> void:
	if Mng.game.status != Game.Status.RUNNING:
		return
	if _target_height < position.y:
		position.y = lerpf(position.y, _target_height, delta * follow_speed)
