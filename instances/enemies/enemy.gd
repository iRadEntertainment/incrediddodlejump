class_name Enemy
extends Area2D

enum Type {
	FLY,
	SPIKES,
}

@onready var sprite: Sprite2D = %sprite
@onready var coll: CollisionShape2D = %coll

var type: Type
var dir: Vector2:
	set(value):
		if dir == value:
			return
		dir = value
		sprite.flip_h = dir.x > 0

var speed: float
var velocity: Vector2
var frames: Array
var frames_duration: float = 0.2
var frames_interval: float
var current_frame_idx: int
var _is_dead: bool


func _ready() -> void:
	Mng.game.enemies.register_enemy(self)
	_setup()


func _setup() -> void:
	pass #NOTE: overlaod


func die() -> void:
	_is_dead = true
	coll.set_deferred(&"disabled", true)
	Mng.game.enemies.deregister_enemy(self)
	queue_free()


func _on_notif_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		area.die(self)
