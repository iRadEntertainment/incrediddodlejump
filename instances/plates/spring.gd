class_name Spring
extends StaticBody2D


@onready var sprite: Sprite2D = %sprite
@onready var sfx_boing: AudioStreamPlayer = %sfx_boing


var jump_force: float = 1800.0


func activate() -> void:
	sfx_boing.play()
	sprite.texture = load("uid://cq8me17b7rtlh")
	await get_tree().create_timer(0.05).timeout
	sprite.texture = load("uid://jtwxff37ccct")
