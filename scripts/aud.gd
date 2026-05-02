# singleton for Audio
extends Node

@onready var music: AudioStreamPlayer = $music
@onready var sfx_game_over: AudioStreamPlayer = %sfx_game_over
@onready var sfx_ready: AudioStreamPlayer = %sfx_ready
@onready var sfx_go: AudioStreamPlayer = %sfx_go

var _tw_theme_music: Tween

#region Volumes
var vol_master: float:
	get:
		return get_bus_volume(0)
	set(value):
		vol_master = value
		set_bus_volume(0, value)
var vol_sfx: float:
	get:
		return get_bus_volume(1)
	set(value):
		vol_sfx = value
		set_bus_volume(1, value)
var vol_music: float:
	get:
		return get_bus_volume(2)
	set(value):
		vol_music = value
		set_bus_volume(2, value)
var vol_ui: float:
	get:
		return get_bus_volume(3)
	set(value):
		vol_ui = value
		set_bus_volume(3, value)
#endregion


func _ready() -> void:
	if Mng.user_file:
		vol_master = Mng.user_file.get_value("Settings", "volume_master", 0.5)
		vol_sfx = Mng.user_file.get_value("Settings", "volume_sfx", 1.0)
		vol_music = Mng.user_file.get_value("Settings", "volume_music", 1.0)
		vol_ui = Mng.user_file.get_value("Settings", "volume_ui", 1.0)


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


#region Getters/setters
func get_bus_volume(bus: int) -> float:
	return AudioServer.get_bus_volume_linear(bus)

func set_bus_volume(bus: int, linear_volume: float) -> void:
	AudioServer.set_bus_volume_linear(bus, linear_volume)
#endregion
