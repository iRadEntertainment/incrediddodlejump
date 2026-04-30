class_name EnemyMng
extends Node2D



var game: Game:
	get: return Mng.game

var enemies_list: Array[Enemy] # enemies self register/deregister on enter/exit tree

var _next_spawn_height: float

func _ready() -> void:
	_next_spawn_height = 500
	#_next_spawn_height = Mng.MAX_ENEMY_SPAWN_HEIGHT
	clear()
	game.status_updated.connect(_on_game_status_updated)
	game.max_height_updated.connect(_on_max_height_updated)


func clear() -> void:
	for enemy: Enemy in enemies_list + get_children():
		enemy.queue_free()


func generate_enemy() -> void:
	var enemy: Enemy = preload("uid://dcp5wrcuq1b1c").instantiate()
	var rng_value: float = Mng.rng.randf()
	if rng_value > 0.7:
		enemy.type = Enemy.Type.SPIKES
	else:
		enemy.type = Enemy.Type.FLY
	
	enemy.position.x = Mng.rng.randf_range(-Mng.viewport_half_size.x, Mng.viewport_half_size.x) * 0.8
	enemy.position.y = -Mng.cam.top_height - 256.0
	Mng.game.enemies.add_child(enemy)


func register_enemy(enemy: Enemy) -> void:
	enemies_list.append(enemy)


func deregister_enemy(enemy: Enemy) -> void:
	if enemies_list.has(enemy):
		enemies_list.erase(enemy)


func _on_max_height_updated(_max_height: float) -> void:
	if _max_height > _next_spawn_height:
		var weight: float = Mng.game.current_difficulty
		_next_spawn_height += floorf( lerpf(Mng.MAX_ENEMY_SPAWN_HEIGHT, Mng.MIN_ENEMY_SPAWN_HEIGHT, weight) )
		_next_spawn_height += Mng.rng.randf_range(-1, 1) * Mng.MIN_ENEMY_SPAWN_HEIGHT * 0.3
		generate_enemy()


func _on_game_status_updated(game_status: Game.Status) -> void:
	if game_status == Game.Status.INIT:
		clear()
