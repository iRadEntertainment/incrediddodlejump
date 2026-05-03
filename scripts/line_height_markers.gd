extends Node2D


func _ready() -> void:
	if Mng.height_previous_run != 0.0:
		_add_marker(Mng.height_previous_run, "Last run", Color(1.0, 0.827, 0.008, 1.0))
	if Mng.height_personal_best != 0.0:
		_add_marker(Mng.height_personal_best, "Max height", Color(0.855, 0.004, 0.184, 1.0))


func _add_marker(height: float, label: String, color: Color) -> void:
	var new_marker: HeightMarker = preload("uid://dmcudpy6vxt8n").instantiate()
	new_marker.position.y = -height
	new_marker.label = label
	new_marker.col = color
	add_child(new_marker)
