class_name Game
extends Node2D

@onready var coll_bot: CollisionShape2D = %coll_bot
@onready var coll_left: CollisionShape2D = %coll_left
@onready var coll_right: CollisionShape2D = %coll_right

@onready var sfx_start: AudioStreamPlayer = %sfx_start
@onready var sfx_game_over: AudioStreamPlayer = %sfx_game_over

@onready var enemies: Node2D = %enemies
@onready var projectiles: Node2D = %projectiles


var grace_deadzone_height = 256.0 #px

enum Status { INIT, RUNNING, GAME_OVER }

var status: Status = Status.INIT:
	set(value):
		if status == value:
			return
		status = value
		set_process(status == Status.RUNNING)
		status_updated.emit(status)
		match status:
			Status.RUNNING: sfx_start.play()
			Status.GAME_OVER: sfx_game_over.play()

var bottom_deadzone_height: float = 0.0
var current_height: float = 0.0
var max_height: float = 0.0:
	set(value):
		if max_height < value:
			max_height = value
			score = floori(max_height)
			max_height_updated.emit(max_height)

var score: int:
	set(value):
		score = value
		var difficulty_ratio: float = (score - Mng.MIN_DIFFICULTY_SCORE) / float(Mng.MAX_DIFFICULTY_SCORE)
		current_difficulty = clampf(difficulty_ratio, 0.0, 1.0)
		score_updated.emit(score)

var current_difficulty: float # between 0 and 1 depending on the score


signal status_updated(status: Status)
signal max_height_updated(max_height: float)
signal score_updated(score: int)


func _init() -> void:
	Mng.game = self
	Mng.rng = RandomNumberGenerator.new()
	Mng.rng.seed = hash("namelesscoder")


func _ready() -> void:
	coll_left.position.x = -Mng.viewport_half_size.x
	coll_right.position.x = Mng.viewport_half_size.x


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released(): return
		match status:
			Status.INIT: start_game()
			Status.GAME_OVER: restart()


func start_game() -> void:
	status = Status.RUNNING


func restart() -> void:
	get_tree().reload_current_scene()


func _process(_delta: float) -> void:
	bottom_deadzone_height = Mng.cam.bottom_height - grace_deadzone_height
	current_height = -Mng.player.position.y
	
	# game over condition
	if current_height < bottom_deadzone_height:
		status = Status.GAME_OVER
	
	# going up
	if max_height < current_height:
		max_height = current_height
