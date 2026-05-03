@tool
extends HBoxContainer

@export var label: String: set = _set_label
@export var bus: int: set = _set_bus
@export var color_unmuted: Color = Color(1.0, 0.992, 0.996, 1.0)
@export var color_muted: Color = Color(0.855, 0.004, 0.184, 1.0)

@onready var lb: Label = $lb
@onready var sl: HSlider = $sl
@onready var lb_value: Label = $lb_value
@onready var btn_mute: Button = %btn_mute

var _lb_settings: LabelSettings
var _is_muted: bool:
	get: return AudioServer.is_bus_mute(bus)
	set(value):
		AudioServer.set_bus_mute(bus, value)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	sl.value = Aud.get_bus_volume(bus)
	
	btn_mute.button_pressed = _is_muted
	
	_lb_settings = lb.label_settings.duplicate()
	lb.label_settings = _lb_settings
	_update_is_muted_color()


func _update_is_muted_color() -> void:
	if not is_node_ready():
		await ready
	_lb_settings.font_color = color_muted if _is_muted else color_unmuted


func _set_label(value: String) -> void:
	label = value
	if not is_node_ready():
		await ready
	lb.text = value


func _set_bus(value: int) -> void:
	bus = value


func _on_sl_value_changed(value: float) -> void:
	if Engine.is_editor_hint():
		return
	Aud.set_bus_volume(bus, value)
	lb_value.text = "%d %%" % (sl.value * 100)


func _on_btn_mute_toggled(toggled_on: bool) -> void:
	_is_muted = toggled_on
	_update_is_muted_color()
