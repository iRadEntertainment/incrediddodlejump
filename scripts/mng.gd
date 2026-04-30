# MNG.gd singleton
extends Node


const PLATFORM_GRID_SIZE: Vector2i = Vector2i(64, 64)

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
