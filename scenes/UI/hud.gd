class_name HUD
extends Control

@onready var lb_score: Label = %lb_score
@onready var lb_state: Label = %lb_state
@onready var prog_difficulty: TextureProgressBar = %prog_difficulty
@onready var prog_personal_best: ProgressBar = %prog_personal_best


func _ready() -> void:
	prog_personal_best.visible = Mng.score_personal_best != 0
	prog_difficulty.value = 0
	Mng.game.score_updated.connect(_on_score_updated)
	
	Mng.state_updated.connect(_on_game_state_updated)
	_on_game_state_updated(Mng.state)


func _on_score_updated(score: int) -> void:
	lb_score.text = "%d" % [score]
	prog_difficulty.value = Mng.game.current_difficulty
	if Mng.game.score < Mng.score_personal_best:
		prog_personal_best.value = Mng.game.score / float(Mng.score_personal_best)


func _on_game_state_updated(game_state: Mng.State) -> void:
	if not is_node_ready():
		await ready
	lb_state.text = str(Mng.State.keys()[game_state as int]).capitalize()
	#lb_state.visible = game_state != Mng.State.RUNNING
