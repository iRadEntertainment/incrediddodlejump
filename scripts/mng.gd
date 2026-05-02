# MNG.gd singleton
extends Node


#region Game modifiers
const PLATFORM_GRID_SIZE: Vector2i = Vector2i(64, 64)

const MIN_DIFFICULTY_SCORE: int = 2000
const MAX_DIFFICULTY_SCORE: int = 40000

const MIN_ENEMY_SPAWN_HEIGHT: int = 300
const MAX_ENEMY_SPAWN_HEIGHT: int = 5000

const SCORE_COST_SHOOT: int = 100
#endregion


#region Self-registering instances
var game: Game
var player: Player
var cam: GameCamera
var gui: GUI
#endregion

#region Window size
var viewport_size: Vector2
var viewport_half_size: Vector2
#endregion

#region Save/Load
const USER_FILE = "incrediball.cfg"
var _user_filepath: String:
	get: return "user://" + USER_FILE
var user_file: ConfigFile
#endregion

#region State
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
enum State { INIT, RUNNING, GAME_OVER, PAUSED }

var state: State = State.INIT: set = _set_state
var state_prev: State
var game_seed: String
var score_personal_best: int
var height_personal_best: int

signal state_updated(state: State)
#endregion


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	viewport_size = get_viewport().get_visible_rect().size
	viewport_half_size = viewport_size * 0.5
	load_user_info()


func load_user_info() -> void:
	if not FileAccess.file_exists(_user_filepath):
		print("Mng: No user file existing.")
		user_file = ConfigFile.new()
		return
	
	user_file = ConfigFile.new()
	var err: Error = user_file.load(_user_filepath)
	if err != OK:
		print("Mng: Cannot load the user file.")
		return
	
	game_seed = user_file.get_value("Stats", "game_seed")
	score_personal_best = user_file.get_value("Stats", "score_personal_best")
	height_personal_best = user_file.get_value("Stats", "height_personal_best")
	
	print("Mng: user file loaded.")


func save_user_file() -> void:
	if not user_file:
		user_file = ConfigFile.new()
	user_file.set_value("Settings", "volume_master", Aud.get_bus_volume(0))
	user_file.set_value("Settings", "volume_sfx", Aud.get_bus_volume(1))
	user_file.set_value("Settings", "volume_music", Aud.get_bus_volume(2))
	user_file.set_value("Settings", "volume_ui", Aud.get_bus_volume(3))
	
	user_file.set_value("Stats", "game_seed", game_seed)
	user_file.set_value("Stats", "score_personal_best", score_personal_best)
	user_file.set_value("Stats", "height_personal_best", height_personal_best)
	
	user_file.save(_user_filepath)


func go_to_title() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func start_game(new_game_seed: String = "") -> void:
	if new_game_seed:
		game_seed = new_game_seed
		rng.seed = hash(game_seed)
	else:
		randomize()
		rng.seed = randi()
	
	get_tree().paused = false
	state = State.INIT
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func restart() -> void:
	save_user_file()
	rng.seed = hash(game_seed)
	state = State.INIT
	get_tree().reload_current_scene()
	await get_tree().scene_changed


func quit() -> void:
	save_user_file()
	if not OS.has_feature("web"):
		get_tree().quit()


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state_prev = state
	state = new_state
	set_process(state == State.RUNNING)
	
	get_tree().paused = not state in [State.RUNNING, State.INIT]
	match state:
		State.INIT: pass
		State.RUNNING: Aud.play_go()
		State.GAME_OVER:
			score_personal_best = max(score_personal_best, Mng.game.score)
			height_personal_best = max(height_personal_best, Mng.game.max_height)
			save_user_file()
	
	state_updated.emit(state)
