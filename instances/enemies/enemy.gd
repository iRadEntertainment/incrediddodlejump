class_name Enemy
extends Area2D

enum Type {
	FLY,
	SPIKES,
}

@onready var sprite: Sprite2D = %sprite
@onready var coll: CollisionShape2D = %coll
@onready var sfx_spawn: AudioStreamPlayer = %sfx_spawn
@onready var sfx_hurt: AudioStreamPlayer = %sfx_hurt

var type: Type
var dir: Vector2:
	set(value):
		if dir == value:
			return
		dir = value
		sprite.flip_h = dir.x > 0

var points: int
var score_lost_on_player_die: int

var speed: float
var velocity: Vector2

var frames: Array
var frames_duration: float = 0.2
var frames_interval: float
var current_frame_idx: int

var can_die: bool
var _is_dead: bool


func _ready() -> void:
	Mng.game.enemies.register_enemy(self)
	Mng.state_updated.connect(_on_game_state_updated)
	_setup()
	sfx_spawn.play()
	tree_exiting.connect(_on_tree_exiting)


func _setup() -> void:
	pass #NOTE: overlaod


func die() -> void:
	if not can_die:
		return
	Mng.game.add_score(points, global_position)
	_is_dead = true
	coll.set_deferred(&"disabled", true)
	Mng.game.enemies.deregister_enemy(self)
	sprite.rotate(randf() * TAU)
	sfx_hurt.play()
	_jump_dead()
	await sfx_hurt.finished
	queue_free()


func _jump_dead() -> void:
	set_process(true)
	velocity.y = -400
	velocity.x = 400


func _process(delta: float) -> void:
	if _is_dead:
		_process_jump_dead(delta)


func _process_jump_dead(delta: float) -> void:
	velocity.y += 980.0 * delta
	position += velocity * delta


func _on_tree_exiting() -> void:
	if not is_instance_valid(Mng.game): return
	if not is_instance_valid(Mng.game.enemies): return
	Mng.game.enemies.deregister_enemy(self)


func _on_notif_screen_exited() -> void:
	if not _is_dead:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		area.die(self)


func _on_game_state_updated(game_state: Mng.State) -> void:
	set_process(game_state != Mng.State.PAUSED)
	set_physics_process(game_state != Mng.State.PAUSED)
