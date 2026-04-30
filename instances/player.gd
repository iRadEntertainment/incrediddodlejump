class_name Player
extends Area2D

@export var g: float = 980.0 #px
@export var jump_force: float = 900.0 #px
@export_range(0.1, 5.0, 0.01) var side_movement_responsivness: float = 3.0 #px

@onready var sprite: Sprite2D = %sprite
@onready var mouth: Sprite2D = %mouth
@onready var marker_eye_l: Marker2D = %marker_eye_l
@onready var marker_eye_r: Marker2D = %marker_eye_r
@onready var eye_l: Sprite2D = %eye_l
@onready var eye_r: Sprite2D = %eye_r

@onready var ray_floor: RayCast2D = %ray_floor
@onready var sfx_jump: AudioStreamPlayer = %sfx_jump


@onready var _marker_eye_l_init_pos: Vector2 = marker_eye_l.position
@onready var _marker_eye_r_init_pos: Vector2 = marker_eye_r.position
@onready var _mouth_init_pos: Vector2 = mouth.position

var velocity: Vector2
var size_x: float


func _init() -> void:
	Mng.player = self


func _ready() -> void:
	size_x = sprite.texture.get_size().x * sprite.scale.x
	set_process(Mng.game.status == Game.Status.RUNNING)
	set_physics_process(Mng.game.status == Game.Status.RUNNING)
	Mng.game.status_updated.connect(_on_game_status_updated)


func _process(delta: float) -> void:
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	_process_eyes(delta)
	_process_mouth(delta)


func _process_eyes(_delta: float) -> void:
	marker_eye_l.position.x = _marker_eye_l_init_pos.x if not sprite.flip_h else -_marker_eye_l_init_pos.x
	marker_eye_r.position.x = _marker_eye_r_init_pos.x if not sprite.flip_h else -_marker_eye_r_init_pos.x
	eye_l.position = marker_eye_l.get_local_mouse_position().normalized() * 4
	eye_r.position = marker_eye_r.get_local_mouse_position().normalized() * 4


func _process_mouth(_delta) -> void:
	mouth.flip_h = sprite.flip_h
	mouth.position.x = _mouth_init_pos.x if not mouth.flip_h else -_mouth_init_pos.x


func _physics_process(delta: float) -> void:
	velocity.y += g * delta
	
	var x_input: float = get_local_mouse_position().x
	velocity.x = lerpf(velocity.x, x_input, delta * side_movement_responsivness)
	
	if velocity.y > 0 and ray_floor.is_colliding():
		var collider: StaticBody2D = ray_floor.get_collider()
		if collider is Spring:
			collider.activate()
			_jump(collider.jump_force, false)
		elif collider is Platform:
			collider.activate()
			if not collider.is_breakable:
				_jump(jump_force)
		else:
			_jump(jump_force)
	
	position += velocity * delta
	
	if abs(position.x) - size_x > Mng.viewport_half_size.x: position.x = - position.x


func _jump(force: float, with_sfx: bool = true) -> void:
	if with_sfx:
		sfx_jump.play()
	velocity.y = -force
	
	var tw_squish: Tween = create_tween()
	tw_squish.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw_squish.tween_property(sprite, ^"scale:y", 0.8, 0.4)
	tw_squish.tween_property(sprite, ^"scale:y", 1.0, 0.4).set_trans(Tween.TRANS_ELASTIC)
	
	mouth.texture = load("res://assets/Characters/incrediball_mouth_closed.png")
	await get_tree().create_timer(0.4).timeout
	mouth.texture = load("res://assets/Characters/incrediball_mouth_open.png")


func _on_game_status_updated(game_status: Game.Status) -> void:
	if game_status == Game.Status.GAME_OVER:
		queue_free()
	set_process(Mng.game.status == Game.Status.RUNNING)
	set_physics_process(Mng.game.status == Game.Status.RUNNING)
