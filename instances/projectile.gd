class_name Projectile
extends Area2D


@onready var sprite: Sprite2D = %sprite
@onready var sfx_burst: AudioStreamPlayer = %sfx_burst
@onready var coll: CollisionShape2D = %coll
@onready var burst_particles: GPUParticles2D = %burst_particles

var dir: Vector2
var speed: float = 1200.0 #px/s


func _physics_process(delta: float) -> void:
	position += dir * speed * delta


func _burst() -> void:
	set_physics_process(false)
	coll.set_deferred(&"disabled", true)
	sprite.hide()
	sfx_burst.play()
	burst_particles.emitting = true
	await sfx_burst.finished
	queue_free()


func _on_notif_screen_exited() -> void:
	queue_free()


func _on_area_entered(enemy: Enemy) -> void:
	if enemy.can_die:
		enemy.die()
	_burst()
