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
var score_previous_run: int
var is_new_score_pb: bool
var height_personal_best: float
var height_previous_run: float

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
	
	game_seed = user_file.get_value("Stats", "game_seed", "namelesscoder")
	score_personal_best = user_file.get_value("Stats", "score_personal_best", 0)
	score_previous_run = user_file.get_value("Stats", "score_previous_run", 0)
	height_personal_best = user_file.get_value("Stats", "height_personal_best", 0.0)
	height_previous_run = user_file.get_value("Stats", "height_previous_run", 0.0)
	
	print("Mng: user file loaded.")
	print("game_seed", game_seed)
	print("score_personal_best", score_personal_best)
	print("score_previous_run", score_previous_run)
	print("height_personal_best", height_personal_best)
	print("height_previous_run", height_previous_run)


func save_user_file() -> void:
	if not user_file:
		user_file = ConfigFile.new()
	user_file.set_value("Settings", "volume_master", Aud.get_bus_volume(0))
	user_file.set_value("Settings", "volume_sfx", Aud.get_bus_volume(1))
	user_file.set_value("Settings", "volume_music", Aud.get_bus_volume(2))
	user_file.set_value("Settings", "volume_ui", Aud.get_bus_volume(3))
	
	user_file.set_value("Stats", "game_seed", game_seed)
	user_file.set_value("Stats", "score_personal_best", score_personal_best)
	user_file.set_value("Stats", "score_previous_run", score_previous_run)
	user_file.set_value("Stats", "height_personal_best", height_personal_best)
	user_file.set_value("Stats", "height_previous_run", height_previous_run)
	
	var err: Error = user_file.save(_user_filepath)
	if err != OK:
		print("Mng: Cannot save the user file at path %s" % (_user_filepath))
	else:
		print("Mng: User file saved -> %s" % (_user_filepath))


func go_to_title() -> void:
	if game:
		if state != State.GAME_OVER:
			state = State.GAME_OVER
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func start_game(new_game_seed: String = "") -> void:
	Aud.stop_title_music()
	if new_game_seed:
		game_seed = new_game_seed
		rng.seed = hash(game_seed)
	else:
		randomize()
		rng.seed = randi()
	
	state = State.INIT
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func restart() -> void:
	if game:
		if state != State.GAME_OVER:
			state = State.GAME_OVER
	
	if game_seed:
		rng.seed = hash(game_seed)
	else:
		randomize()
		rng.seed = randi()
	
	save_user_file()
	rng.seed = hash(game_seed)
	state = State.INIT
	get_tree().reload_current_scene()
	await get_tree().scene_changed


func quit() -> void:
	if game:
		if state != State.GAME_OVER:
			state = State.GAME_OVER
	save_user_file()
	if not OS.has_feature("web"):
		get_tree().quit()


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state_prev = state
	state = new_state
	set_process(state == State.RUNNING)
	
	match new_state:
		State.INIT:
			if is_instance_valid(game):
				score_previous_run = game.score
				height_previous_run = game.max_height
		State.RUNNING:
			if state_prev != State.PAUSED:
				Aud.play_go()
		State.GAME_OVER:
			is_new_score_pb = score_personal_best < game.score
			score_personal_best = max(score_personal_best, game.score)
			height_personal_best = max(height_personal_best, game.max_height)
			save_user_file()
	
	state_updated.emit(state)
