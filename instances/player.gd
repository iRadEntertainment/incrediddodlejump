class_name Player
extends Area2D

@export var g: float = 980.0 #px
@export var jump_force: float = 900.0 #px
@export_range(0.1, 5.0, 0.01) var side_movement_responsivness: float = 3.0 #px

@onready var sprite: Sprite2D = %sprite
@onready var mouth: Sprite2D = %mouth
@onready var shoot_marker: Marker2D = %shoot_marker

@onready var marker_eye_l: Marker2D = %marker_eye_l
@onready var marker_eye_r: Marker2D = %marker_eye_r
@onready var eye_l: Sprite2D = %eye_l
@onready var eye_r: Sprite2D = %eye_r

@onready var ray_floor: RayCast2D = %ray_floor
@onready var sfx_jump: AudioStreamPlayer = %sfx_jump
@onready var sfx_shoot: AudioStreamPlayer = %sfx_shoot
@onready var sfx_die: AudioStreamPlayer = %sfx_die

@onready var _marker_eye_l_init_pos: Vector2 = marker_eye_l.position
@onready var _marker_eye_r_init_pos: Vector2 = marker_eye_r.position
@onready var _mouth_init_pos: Vector2 = mouth.position

var velocity: Vector2
var size_x: float
var is_dead: bool



func _init() -> void:
	Mng.player = self


func _ready() -> void:
	size_x = sprite.texture.get_size().x * sprite.scale.x
	set_process(Mng.state == Mng.State.RUNNING)
	set_physics_process(Mng.state == Mng.State.RUNNING)
	Mng.state_updated.connect(_on_game_state_updated)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"shoot") and not is_dead:
		_shoot()


func _process(delta: float) -> void:
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	
	if is_dead:
		return
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
	
	var x_input: float = 0.0
	if not is_dead:
		x_input = get_local_mouse_position().x
	
	velocity.x = lerpf(velocity.x, x_input, delta * side_movement_responsivness)
	
	if velocity.y > 0 and ray_floor.is_colliding() and not is_dead:
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
	_squish()
	_close_mouth()


func _shoot() -> void:
	if Mng.game.score < Mng.SCORE_COST_SHOOT:
		return
	Mng.game.score_spent += Mng.SCORE_COST_SHOOT
	
	var proj: Projectile = preload("uid://1pytnpnd7c2h").instantiate()
	proj.position = shoot_marker.global_position
	proj.dir = shoot_marker.get_local_mouse_position().normalized()
	Mng.game.projectiles.add_child(proj)
	
	sfx_shoot.play()
	_close_mouth()


func _squish() -> void:
	var tw_squish: Tween = create_tween()
	tw_squish.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw_squish.tween_property(sprite, ^"scale:y", 0.8, 0.4)
	tw_squish.tween_property(sprite, ^"scale:y", 1.0, 0.4).set_trans(Tween.TRANS_ELASTIC)


func _close_mouth() -> void:
	mouth.texture = load("res://assets/Characters/incrediball_mouth_closed.png")
	await get_tree().create_timer(0.4).timeout
	mouth.texture = load("res://assets/Characters/incrediball_mouth_open.png")


func die(by_enemy: Enemy = null) -> void:
	is_dead = true
	if by_enemy:
		var diff_vector: Vector2 = by_enemy.position.direction_to(position).normalized()
		velocity = diff_vector * 200
	sfx_die.play()
	
	await get_tree().create_timer(1.0).timeout
	Mng.game.game_over()


func _on_game_state_updated(game_state: Mng.State) -> void:
	if game_state == Mng.State.GAME_OVER:
		queue_free()
	set_process(Mng.state == Mng.State.RUNNING)
	set_physics_process(Mng.state == Mng.State.RUNNING)
