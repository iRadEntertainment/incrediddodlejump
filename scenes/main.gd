extends Control

@onready var tabs: TabContainer = %tabs
@onready var btn_back: Button = %btn_back


func _ready() -> void:
	btn_back.hide()
	get_tree().paused = false
	tabs.current_tab = 0
	Aud.play_title_music()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if btn_back.is_visible_in_tree():
			_on_btn_back_pressed()


func _on_btn_back_pressed() -> void: tabs.current_tab = 0
func _on_btn_play_pressed() -> void: tabs.current_tab = 1
func _on_btn_settings_pressed() -> void: tabs.current_tab = 2
func _on_btn_credits_pressed() -> void: tabs.current_tab = 3
func _on_btn_quit_pressed() -> void: Mng.quit()

func _on_tabs_tab_changed(tab: int) -> void:
	if not is_node_ready():
		await ready
	btn_back.visible = tab != 0
