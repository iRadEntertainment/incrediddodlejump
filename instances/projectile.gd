class_name Projectile
extends Area2D


var dir: Vector2
var speed: float = 1200.0 #px/s


func _physics_process(delta: float) -> void:
	position += dir * speed * delta


func _on_notif_screen_exited() -> void:
	queue_free()


func _on_area_entered(enemy: Enemy) -> void:
	enemy.die()
	queue_free()
