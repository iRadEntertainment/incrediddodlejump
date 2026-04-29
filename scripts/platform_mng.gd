class_name PlatformsMng
extends Node2D

const OFF_SCREEN_GEN_HEIGHT: float = float(Mng.PLATFORM_GRID_SIZE.y * 2)

#@export var noise: FastNoiseLite
@export_range(0, 8, 1) var max_skippable_platforms: int = 4

var game: Game:
	get: return Mng.game

var _generated_height: float = Mng.PLATFORM_GRID_SIZE.y * 2.0
var _gen_target_height: float:
	get: return snappedf(Mng.cam.top_height + OFF_SCREEN_GEN_HEIGHT, Mng.PLATFORM_GRID_SIZE.y)
var _lines_to_generate: int:
	get: return floori((_gen_target_height - _generated_height) / Mng.PLATFORM_GRID_SIZE.y)
var _skipped_platform_count: int


func _ready() -> void:
	game.status_updated.connect(_on_game_status_updated)
	clear()
	generate_platforms()
	Mng.game.max_height_updated.connect(_on_max_height_updated)


func _on_max_height_updated(_max_height: float) -> void:
	if _lines_to_generate > 0:
		generate_platforms()


func clear() -> void:
	for platform: Platform in get_children():
		platform.queue_free()


func generate_platforms() -> void:
	#if not noise:
		#printerr("No noise assigned to the platform manager.")
		#return
	
	for line: int in _lines_to_generate:
		var spawn_platform: bool = Mng.rng.randf() < 0.5
		spawn_platform = spawn_platform or _skipped_platform_count >= max_skippable_platforms
		
		if not spawn_platform:
			_skipped_platform_count += 1
			continue
		
		_skipped_platform_count = 0
		
		var line_height: float = _generated_height + line * Mng.PLATFORM_GRID_SIZE.y
		var platform: Platform = load("uid://bnnasjoucdkug").instantiate()
		platform.position.y = -line_height
		platform.position.x = (Mng.rng.randf() * 2.0 - 1.0) * Mng.viewport_half_size.x
		platform.is_moving = Mng.rng.randf() > 0.8
		platform.has_spring = Mng.rng.randf() > 0.9
		add_child(platform)
	
	_generated_height = _gen_target_height


func _on_game_status_updated(game_status: Game.Status) -> void:
	if game_status == Game.Status.INIT:
		clear()
		generate_platforms()
