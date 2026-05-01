class_name GUI
extends CanvasLayer


@onready var hud: HUD = %hud
@onready var in_game_menu: InGameMenu = %in_game_menu


func _init() -> void:
	Mng.gui = self


#func _ready() -> void:
	#in_game_menu.visibility_changed.connect(_on_menu_visibility_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		toggle_in_game_menu()


func toggle_in_game_menu() -> void:
	in_game_menu.visible = !in_game_menu.visible
	if in_game_menu.visible:
		Mng.state = Mng.State.PAUSED
	else:
		Mng.state = Mng.state_prev


#func _on_menu_visibility_changed() -> void:
	#get_tree().paused = visible
