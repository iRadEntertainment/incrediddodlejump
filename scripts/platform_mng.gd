class_name PlatformsMng
extends Node2D

const OFF_SCREEN_GEN_HEIGHT: float = float(Mng.PLATFORM_GRID_SIZE.y * 2)

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
	Mng.state_updated.connect(_on_game_state_updated)
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
	# probability to skip
	var pr_skip: float = lerpf(0.3, 0.85, Mng.game.current_difficulty)
	
	for line: int in _lines_to_generate:
		# difficulty spawn
		var rng_skip: bool = Mng.rng.randf() < pr_skip
		var can_skip: bool = _skipped_platform_count < max_skippable_platforms
		var skip_platform: bool = rng_skip and can_skip
		
		if skip_platform:
			_skipped_platform_count += 1
			continue
		
		# difficulty probabilities modifiers
		var pr_is_moving: float = lerpf(0.0, 0.65, Mng.game.current_difficulty)
		var pr_is_disappear: float = lerpf(0.0, 0.3, Mng.game.current_difficulty)
		var pr_is_breakable: float = lerpf(0.2, 0.5, Mng.game.current_difficulty)
		var pr_is_long: float = lerpf(0.4, 0.05, Mng.game.current_difficulty)
		var pr_has_spring: float = lerpf(0.03, 0.15, Mng.game.current_difficulty)
		var pr_has_boost: float = lerpf(0.02, 0.04, Mng.game.current_difficulty)
		
		# add platform
		var line_height: float = _generated_height + line * Mng.PLATFORM_GRID_SIZE.y
		var platform: Platform = load("uid://bnnasjoucdkug").instantiate()
		platform.position.y = -line_height
		platform.position.x = (Mng.rng.randf() * 2.0 - 1.0) * Mng.viewport_half_size.x
		platform.is_moving = Mng.rng.randf() < pr_is_moving
		platform.is_disappear = Mng.rng.randf() < pr_is_disappear
		platform.is_breakable = (Mng.rng.randf() < pr_is_breakable) and can_skip and not platform.is_disappear
		platform.is_long = Mng.rng.randf() < pr_is_long
		platform.has_spring = (Mng.rng.randf() < pr_has_spring) and not platform.is_breakable
		platform.has_boost = (Mng.rng.randf() < pr_has_boost) and not platform.is_breakable
		add_child(platform)
		
		# count skipped platforms (breakable)
		if platform.is_breakable:
			_skipped_platform_count += 1
		else:
			_skipped_platform_count = 0
	
	_generated_height = _gen_target_height


func _on_game_state_updated(game_state: Mng.State) -> void:
	if game_state == Mng.State.INIT:
		clear()
		generate_platforms()
