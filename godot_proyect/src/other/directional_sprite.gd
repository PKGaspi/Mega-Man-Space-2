
extends AnimatedSprite

export(SpriteFrames) var palettes
var direction: Vector2


func set_direction(value: Vector2) -> void:
	direction = value
	# Set rotation sprite.
	if direction == Vector2.ZERO: # Iddle.
		set_animation("iddle")
	else:
		var degrees_per_direction = 360 / 8
		var propulsion_angle = int(round(rad2deg(direction.angle() - global_rotation)))
		# Work only with positive angles.
		if propulsion_angle < 0:
			propulsion_angle += 360
		# Make the angle change in an interval of 45 / 2 degs.
		if propulsion_angle % degrees_per_direction >= degrees_per_direction / 2:
			propulsion_angle += degrees_per_direction - propulsion_angle % degrees_per_direction
		else:
			propulsion_angle -= propulsion_angle % degrees_per_direction
		propulsion_angle %= 360
		# Set the corresponding mask
		set_animation(str(propulsion_angle))
	
	play()


func set_animation(value: String) -> void:
	if frames.has_animation(value):
		.set_animation(value)
		set_mask(frame)


func set_palette(value: int) -> void:
	if material != null:
		material.set_shader_param("palette", palettes.get_frame("default", value))
		

func set_mask(value: int) -> void:
	if material != null:
		material.set_shader_param("mask", frames.get_frame(animation, value))

func _on_frame_changed() -> void:
	set_mask(frame)
