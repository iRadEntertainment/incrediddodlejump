class_name InGameMenu
extends Control


func _ready() -> void:
	hide()


func _on_btn_title_pressed() -> void:
	Mng.go_to_title()


func _on_btn_restart_pressed() -> void:
	Mng.restart()
