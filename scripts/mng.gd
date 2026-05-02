# MNG.gd singleton
extends Node


const PLATFORM_GRID_SIZE: Vector2i = Vector2i(64, 64)

const MIN_DIFFICULTY_SCORE: int = 2000
const MAX_DIFFICULTY_SCORE: int = 40000

const MIN_ENEMY_SPAWN_HEIGHT: int = 300
const MAX_ENEMY_SPAWN_HEIGHT: int = 5000

const SCORE_COST_SHOOT: int = 100


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

#region State
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
enum State { INIT, RUNNING, GAME_OVER, PAUSED }

var state: State = State.INIT: set = _set_state
var state_prev: State
var game_seed: String

signal state_updated(state: State)
#endregion


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	viewport_size = get_viewport().get_visible_rect().size
	viewport_half_size = viewport_size * 0.5


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
	rng.seed = hash(game_seed)
	state = State.INIT
	get_tree().reload_current_scene()
	await get_tree().scene_changed


func quit() -> void:
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
		State.GAME_OVER: pass
	
	state_updated.emit(state)
