extends PanelContainer

const LIST_FILEPATH: String = "res://assets/rng_seed_list.txt"

@onready var ln_seed: LineEdit = %ln_seed

var _rng_seed_list: PackedStringArray


func _ready() -> void:
	_load_rng_seed_list()
	if Mng.game_seed:
		ln_seed.text = Mng.game_seed


func _load_rng_seed_list() -> void:
	var f: FileAccess = FileAccess.open(LIST_FILEPATH, FileAccess.READ)
	var content: String = f.get_as_text()
	_rng_seed_list = content.split("\n")


func _on_btn_play_pressed() -> void:
	Mng.start_game(ln_seed.text)


func _on_btn_random_seed_pressed() -> void:
	ln_seed.text = _rng_seed_list[randi() % _rng_seed_list.size()]
