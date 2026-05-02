# singleton for Audio
extends Node

@onready var music: AudioStreamPlayer = $music
@onready var sfx_game_over: AudioStreamPlayer = %sfx_game_over
@onready var sfx_ready: AudioStreamPlayer = %sfx_ready
@onready var sfx_go: AudioStreamPlayer = %sfx_go


func _ready() -> void:
	play_theme_music()


func play_theme_music() -> void: music.play()
func play_ready() -> void: sfx_ready.play()
func play_go() -> void: sfx_go.play(); sfx_ready.stop()
func play_womp_womp() -> void: sfx_game_over.play()
