class_name Player
extends Area2D

@export var g: float = 980.0 #px
@export var jump_force: float = 900.0 #px
@export_range(0.1, 5.0, 0.01) var side_movement_responsivness: float = 3.0 #px

@onready var sprite: Sprite2D = %sprite
@onready var ray_floor: RayCast2D = %ray_floor
@onready var sfx_jump: AudioStreamPlayer = %sfx_jump

var velocity: Vector2
var size_x: float


func _init() -> void:
	Mng.player = self


func _ready() -> void:
	size_x = sprite.texture.get_size().x * sprite.scale.x
	set_process(Mng.game.status == Game.Status.RUNNING)
	set_physics_process(Mng.game.status == Game.Status.RUNNING)
	Mng.game.status_updated.connect(_on_game_status_updated)


func _process(_delta: float) -> void:
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


func _physics_process(delta: float) -> void:
	velocity.y += g * delta
	
	var x_input: float = get_local_mouse_position().x
	velocity.x = lerpf(velocity.x, x_input, delta * side_movement_responsivness)
	
	if velocity.y > 0 and ray_floor.is_colliding():
		var collider: StaticBody2D = ray_floor.get_collider()
		if collider is Spring:
			collider.activate()
			velocity.y = -collider.jump_force
		else:
			velocity.y = -jump_force
			sfx_jump.play()
	
	position += velocity * delta
	
	if abs(position.x) - size_x > Mng.viewport_half_size.x: position.x = - position.x


func _on_game_status_updated(game_status: Game.Status) -> void:
	if game_status == Game.Status.GAME_OVER:
		queue_free()
	set_process(Mng.game.status == Game.Status.RUNNING)
	set_physics_process(Mng.game.status == Game.Status.RUNNING)
