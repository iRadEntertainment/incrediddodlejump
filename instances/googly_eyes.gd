extends Node2D

@onready var marker_eye_l: Marker2D = %marker_eye_l
@onready var eye_l: Sprite2D = %eye_l
@onready var marker_eye_r: Marker2D = %marker_eye_r
@onready var eye_r: Sprite2D = %eye_r



func _process(_delta: float) -> void:
	eye_l.position = marker_eye_l.get_local_mouse_position().normalized() * 4
	eye_r.position = marker_eye_r.get_local_mouse_position().normalized() * 4
