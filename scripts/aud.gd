# singleton for Audio
extends Node

@onready var music: AudioStreamPlayer = $music
@onready var sfx_start: AudioStreamPlayer = %sfx_start
@onready var sfx_game_over: AudioStreamPlayer = %sfx_game_over

func _ready() -> void:
	play_theme_music()


func play_theme_music() -> void:
	music.play()
