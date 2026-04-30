# singleton for Audio
extends Node

@onready var music: AudioStreamPlayer = $music


func _ready() -> void:
	play_theme_music()


func play_theme_music() -> void:
	music.play()
