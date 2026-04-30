class_name Spring
extends StaticBody2D

const REGION_SPRING_DOWN: Rect2 = Rect2(65, 455, 64, 64)
const REGION_SPRING_UP: Rect2 = Rect2(130, 455, 64, 64)

@onready var sprite: Sprite2D = %sprite
@onready var sfx_boing: AudioStreamPlayer = %sfx_boing


var jump_force: float = 1800.0

var _atlas_tex: AtlasTexture:
	get: return sprite.texture


func _ready() -> void:
	_atlas_tex.region = REGION_SPRING_DOWN


func activate() -> void:
	sfx_boing.play()
	_atlas_tex.region = REGION_SPRING_DOWN
	await get_tree().create_timer(0.05).timeout
	_atlas_tex.region = REGION_SPRING_UP
