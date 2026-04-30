extends Enemy


const FRAMES: Dictionary[Type, Array] = {
	Type.FLY: [18, 19],
	Type.SPIKES: [31, 32],
}


func _setup() -> void:
	dir.x = 1 if Mng.rng.randf() > 0.5 else -1
	
	frames = FRAMES[type]
	match type:
		Type.FLY:
			can_die = true
			speed = 120.0
			sfx_spawn.stream = load("uid://cout3m0rgorst")
		Type.SPIKES:
			can_die = false
			speed = 60.0
			sfx_spawn.stream = load("uid://d3hhvys70atoa")


func _process(delta: float) -> void:
	frames_interval += delta
	if frames_interval > frames_duration:
		frames_interval = 0
		current_frame_idx = wrapi(current_frame_idx + 1, 0, frames.size())
		sprite.frame = frames[current_frame_idx]


func _physics_process(delta: float) -> void:
	_process_bounce_left_right()
	velocity = speed * dir
	position += velocity * delta


func _process_bounce_left_right() -> void:
	if dir.x > 0.0 and global_position.x > Mng.viewport_half_size.x or \
			dir.x < 0.0 and global_position.x < -Mng.viewport_half_size.x:
		dir.x = -dir.x
