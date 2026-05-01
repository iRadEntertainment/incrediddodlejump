class_name InGameMenu
extends Control

@onready var btn_quit: Button = %btn_quit


func _ready() -> void:
	hide()
	btn_quit.visible = not OS.has_feature("web")


func _on_btn_title_pressed() -> void:
	Mng.go_to_title()


func _on_btn_restart_pressed() -> void:
	Mng.restart()


func _on_btn_quit_pressed() -> void:
	Mng.quit()
