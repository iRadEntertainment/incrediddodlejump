# MNG.gd singleton
extends Node


const PLATFORM_GRID_SIZE: Vector2i = Vector2i(64, 64)
const MIN_DIFFICULTY_SCORE: int = 2000
const MAX_DIFFICULTY_SCORE: int = 40000
const MIN_ENEMY_SPAWN_HEIGHT: int = 1200
const MAX_ENEMY_SPAWN_HEIGHT: int = 5000


#region Self-registering instances
var game: Game
var rng: RandomNumberGenerator
var player: Player
var cam: GameCamera
var gui: GUI
#endregion

var os_platform: Script = preload("uid://ckkwcaqpa3klg")
var viewport_size: Vector2
var viewport_half_size: Vector2


func _ready() -> void:
	viewport_size = get_viewport().get_visible_rect().size
	viewport_half_size = viewport_size * 0.5
