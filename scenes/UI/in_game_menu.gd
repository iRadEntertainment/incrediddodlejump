class_name InGameMenu
extends Control


@onready var tabs: TabContainer = %tabs


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	hide()


func _on_visibility_changed() -> void:
	if visible:
		tabs.current_tab = 0


func _on_btn_title_pressed() -> void: Mng.go_to_title()
func _on_btn_restart_pressed() -> void: Mng.restart()
func _on_btn_settings_pressed() -> void: tabs.current_tab = 1
func _on_btn_back_pressed() -> void: tabs.current_tab = 0
