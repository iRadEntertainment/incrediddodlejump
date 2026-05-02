class_name ScoreFloat
extends Node2D

const ROTATION: float = 0.47123889803846897 # PI * 0.15
const COL_PLUS: Color = Color(0.531, 1.0, 0.578, 1.0)
const COL_MINUS: Color = Color(0.855, 0.004, 0.184, 1.0)

@onready var lb: Label = $lb

var score: int


func _ready() -> void:
	var final_text: String = "+" if score > 0 else ""
	final_text += "%d" % score
	lb.text = final_text
	var score_color: Color = COL_PLUS if score > 0 else COL_MINUS
	lb.add_theme_color_override(&"font_color", score_color)
	_float_and_disappear()


func _float_and_disappear() -> void:
	
	rotation = randf_range(-ROTATION, ROTATION)
	
	var tw: Tween = create_tween()
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.set_parallel()
	tw.tween_property(self, ^"modulate:a", 1.0, 0.2)
	tw.tween_property(self, ^"scale", Vector2.ONE, 0.4)
	tw.tween_property(self, ^"position:y", -120.0, 0.5).as_relative()
	tw.chain().tween_property(self, ^"modulate:a", 0.0, 0.2)
	tw.tween_property(self, ^"scale", Vector2.ZERO, 0.4)
	
	await tw.finished
	queue_free()
