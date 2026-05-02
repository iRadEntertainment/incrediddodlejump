# singleton for Audio
extends Node

@onready var music: AudioStreamPlayer = $music
@onready var sfx_game_over: AudioStreamPlayer = %sfx_game_over
@onready var sfx_ready: AudioStreamPlayer = %sfx_ready
@onready var sfx_go: AudioStreamPlayer = %sfx_go

var _tw_theme_music: Tween


#region Music
func play_theme_music() -> void:
	if _tw_theme_music:
		_tw_theme_music.kill()
	_tw_theme_music = create_tween()
	music.play()
	_tw_theme_music.tween_property(music, ^"volume_linear", 1.0, 0.5).from(0.0)


func stop_theme_music() -> void:
	if _tw_theme_music:
		_tw_theme_music.kill()
	_tw_theme_music = create_tween()
	_tw_theme_music.tween_property(music, ^"volume_linear", 0.0, 0.5)
	_tw_theme_music.tween_callback(music.stop)
#endregion


#region Game state
func play_ready() -> void: sfx_ready.play()
func play_go() -> void: sfx_go.play(); sfx_ready.stop()
func play_womp_womp() -> void:
	sfx_game_over.play()
	stop_theme_music()
#endregion
