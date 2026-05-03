extends PanelContainer

@onready var ln_seed: LineEdit = %ln_seed

func _ready() -> void:
	if Mng.game_seed:
		ln_seed.text = Mng.game_seed


func _on_btn_play_pressed() -> void:
	Mng.start_game(ln_seed.text)
