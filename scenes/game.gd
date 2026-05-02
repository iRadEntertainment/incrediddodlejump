class_name Game
extends Node2D

@onready var coll_bot: CollisionShape2D = %coll_bot
@onready var coll_left: CollisionShape2D = %coll_left
@onready var coll_right: CollisionShape2D = %coll_right

@onready var enemies: Node2D = %enemies
@onready var projectiles: Node2D = %projectiles
@onready var score_container: Node2D = %score_container


var grace_deadzone_height = 256.0 #px

var bottom_deadzone_height: float = 0.0
var current_height: float = 0.0
var max_height: float = 0.0:
	set(value):
		if max_height < value:
			max_height = value
			score_raw = floori(max_height)
			max_height_updated.emit(max_height)

var score_raw: int:
	set(value):
		score_raw = value
		var difficulty_ratio: float = inverse_lerp(Mng.MIN_DIFFICULTY_SCORE, Mng.MAX_DIFFICULTY_SCORE, score_raw)
		current_difficulty = clampf(difficulty_ratio, 0.0, 1.0)
		score_updated.emit(score)
var score_gained: int:
	set(value):
		score_gained = value
		score_updated.emit(score)
var score_spent: int:
	set(value):
		score_spent = value
		score_updated.emit(score)
var score: int:
	get: return max(score_raw + score_gained - score_spent, 0)



var current_difficulty: float # between 0 and 1 depending on the score_raw

signal max_height_updated(max_height: float)
signal score_updated(score_raw: int)


func _init() -> void:
	Mng.game = self


func _ready() -> void:
	get_tree().paused = false
	coll_left.position.x = -Mng.viewport_half_size.x
	coll_right.position.x = Mng.viewport_half_size.x
	Aud.play_ready()


func game_over() -> void:
	Aud.play_womp_womp()
	Mng.state = Mng.State.GAME_OVER


func add_score(added_score: int, score_position: Vector2) -> void:
	if added_score > 0:
		score_gained += added_score
	else:
		score_spent += added_score
	var score_float: ScoreFloat = preload("uid://bbi4q4ggfvo2b").instantiate()
	score_float.score = added_score
	score_float.position = score_position
	score_container.add_child(score_float)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released(): return
		match Mng.state:
			Mng.State.INIT:
				Mng.state = Mng.State.RUNNING
				Aud.play_theme_music()
			Mng.State.GAME_OVER: Mng.gui.toggle_in_game_menu()


func _process(_delta: float) -> void:
	bottom_deadzone_height = Mng.cam.bottom_height - grace_deadzone_height
	current_height = -Mng.player.position.y
	
	# game over condition
	if current_height < bottom_deadzone_height:
		Aud.play_womp_womp()
		Mng.state = Mng.State.GAME_OVER
	
	# going up
	if max_height < current_height:
		max_height = current_height
