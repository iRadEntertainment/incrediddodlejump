class_name HeightMarker
extends Line2D


@onready var poly: Polygon2D = %poly
@onready var hb_text: HBoxContainer = %hb_text
@onready var lb: Label = %lb
@onready var lb_value: Label = %lb_value

var label: String
var col: Color = Color(0.392, 0.588, 0.82, 1.0)
var col_line_alpha: float = 0.6

var _lb_settings: LabelSettings


func _ready() -> void:
	_lb_settings = lb.label_settings.duplicate()
	lb.label_settings = _lb_settings
	lb_value.label_settings = _lb_settings
	_update()


func _update() -> void:
	# line
	points[0].x = -Mng.viewport_half_size.x
	points[1].x =  Mng.viewport_half_size.x
	var col_line: Color = col
	col_line.a = col_line_alpha
	default_color = col_line
	
	# polygon
	poly.color = col
	poly.position.x = Mng.viewport_half_size.x
	
	# text
	hb_text.position.x = -Mng.viewport_size.x
	hb_text.size.x = Mng.viewport_size.x
	
	_lb_settings.font_color = col
	lb.text = label
	lb_value.text = "%.1f" % (-position.y)

func _on_notif_screen_exited() -> void:
	queue_free()
