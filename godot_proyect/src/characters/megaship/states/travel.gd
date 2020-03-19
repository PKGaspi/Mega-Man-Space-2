extends CharacterState

const MIN_DISTANCE_TO_CURSOR = 5 # In pixels.

func _ready() -> void:
	pass

func physics_process(delta: float) -> void:
	# Calculate movement.
	var input_dir = get_input_direction()
	var acceleration = _parent.acceleration_ratio * _parent.max_speed
	_parent.velocity = calculate_velocity(input_dir, acceleration, _parent.velocity, delta)

	# Calculate rotation.
	character.rotation = calculate_rotation()
	
	# Emit propulsion particles and calculate inclination sprite.
	var propulsion = input_dir.normalized() * acceleration
	character.apply_propulsion_effects(propulsion)
	
	# Call the parent state's method to apply movement.
	_parent.physics_process(delta)
	
	# Get collisions.
	var collider = _parent.get_collided_character()
	if collider != null:
		collider.collide(character)
		if collider is Pickup:
			pass # Do nothing.
		elif collider is Enemy and character.invencible:
			# Get knockbacked./
			var dir = collider.global_position.direction_to(character.global_position)
			_state_machine.transition_to("Move/Knockback", {"knockback_dir": dir})


## Auxiliar functions. ##

func get_input_direction(normalized:= false) -> Vector2:
	# TODO: Implement touchscreen controls.
	# This should work for keyboard and gamepad.
	
	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	if input_dir.length() > 1:
		# Allow module <= 1.
		input_dir = input_dir.normalized()
	
	return input_dir


func calculate_velocity(
	move_direction: Vector2,
	acceleration: float,
	current_velocity: Vector2,
	delta: float
) -> Vector2:
	
	var new_velocity: Vector2 
	if move_direction != Vector2.ZERO:
		# Accelerate.
		new_velocity = current_velocity + move_direction * acceleration * delta
	else:
		# Deaccelerate.
		var to_substract = current_velocity.normalized() * (acceleration * 4 / 5) * delta
		if current_velocity.length() < to_substract.length():
			# Stay in place if we are going the other way.
			new_velocity = Vector2.ZERO
		else:
			# Reduce velocity.
			new_velocity = current_velocity - to_substract
	
	current_velocity = new_velocity
	return new_velocity


func calculate_rotation() -> float:
	var rotation:= character.rotation
	
	match global.input_type:
		global.INPUT_TYPES.KEY_MOUSE: # Keyboard and mouse input.
			var mouse_pos = character.get_global_mouse_position()
			var global_position = character.global_position
			if global_position.distance_to(mouse_pos) > MIN_DISTANCE_TO_CURSOR:
				rotation = global_position.direction_to(mouse_pos).angle()
		_:
			pass #rotation = 
	return rotation
