class_name GUI
extends CanvasLayer


@onready var lb_score: Label = %lb_score
@onready var lb_status: Label = %lb_status
@onready var prog_difficulty: TextureProgressBar = %prog_difficulty


func _init() -> void:
	Mng.gui = self


func _ready() -> void:
	Mng.game.score_updated.connect(_on_score_updated)
	Mng.game.status_updated.connect(_on_game_status_updated)
	_on_game_status_updated(Mng.game.status)


func _on_score_updated(score: int) -> void:
	lb_score.text = "%d" % [score]
	prog_difficulty.value = Mng.game.current_difficulty


func _on_game_status_updated(game_status: Game.Status) -> void:
	lb_status.text = str(Game.Status.keys()[game_status as int]).capitalize()
	lb_status.visible = game_status != Game.Status.RUNNING
