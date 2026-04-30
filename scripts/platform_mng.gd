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
	game.max_height_updated.connect(_on_max_height_updated)


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
	
	var spawn_treshold_difficulty: float = 0.5
	
	for line: int in _lines_to_generate:
		# difficulty spawn
		var rng_skip: bool = Mng.rng.randf() > spawn_treshold_difficulty
		var can_skip: bool = _skipped_platform_count < max_skippable_platforms
		var skip_platform: bool = rng_skip and can_skip
		
		if skip_platform:
			_skipped_platform_count += 1
			continue
		
		# difficulty modifiers
		var is_moving: bool = Mng.rng.randf() > 0.8
		var is_disappear: bool = Mng.rng.randf() > 0.9
		var is_breakable: bool = Mng.rng.randf() > 0.9 and can_skip and not is_disappear
		var is_long: bool = Mng.rng.randf() > 0.6
		var has_spring: bool = Mng.rng.randf() > 0.9 and not is_breakable
		var has_boost: bool = false and not is_breakable # TODO
		
		if is_breakable:
			_skipped_platform_count += 1
		else:
			_skipped_platform_count = 0
		
		
		var line_height: float = _generated_height + line * Mng.PLATFORM_GRID_SIZE.y
		var platform: Platform = load("uid://bnnasjoucdkug").instantiate()
		platform.position.y = -line_height
		platform.position.x = (Mng.rng.randf() * 2.0 - 1.0) * Mng.viewport_half_size.x
		platform.is_moving = is_moving
		platform.is_breakable = is_breakable
		platform.is_disappear = is_disappear
		platform.is_long = is_long
		platform.has_spring = has_spring
		platform.has_boost = has_boost
		add_child(platform)
	
	_generated_height = _gen_target_height


func _on_game_status_updated(game_status: Game.Status) -> void:
	if game_status == Game.Status.INIT:
		clear()
		generate_platforms()
