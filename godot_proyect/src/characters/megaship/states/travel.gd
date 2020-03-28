extends CharacterState

const MIN_DISTANCE_TO_CURSOR = 5 # In pixels.

var cannons

func _ready() -> void:
	yield(owner, "ready")
	cannons = character.cannons


func enter(msg: Dictionary = {}) -> void:
	# Allow cannon shooting.
	cannons.state_machine.transition_to(cannons.weapon_to_state(cannons.weapon))
	if msg.has("velocity"):
		_parent.velocity = msg["velocity"]


func exit() -> void:
	# Disable cannon shooting.
	cannons.state_machine.transition_to("Disabled")


func physics_process(delta: float) -> void:
	# Calculate movement.
	var input_dir = get_input_direction()
	var acceleration = _parent.acceleration_ratio * _parent.max_speed
	_parent.velocity = _parent.calculate_velocity(input_dir, acceleration, _parent.velocity, delta)

	# Calculate rotation.
	character.global_rotation = calculate_rotation()
	
	# Emit propulsion particles and calculate inclination sprite.
	var propulsion
	if input_dir.length() > 1:
		propulsion = input_dir.normalized() * acceleration
	else:
		propulsion = input_dir * acceleration
	character.apply_propulsion_effects(propulsion)
	
	# Call the parent state's method to apply movement.
	_parent.physics_process(delta)
	
	# Get collisions.
	var collider = _parent.get_collided_character()
	if collider != null:
		if collider is Pickup:
			# TODO: Apply the pickup effect.
			pass 
		elif collider is Character and not character.invencible:
			# Get hit and knockbacked.
			character.hit(collider.collision_damage)
			var dir = collider.global_position.direction_to(character.global_position)
			_state_machine.transition_to("Move/Knockback", {"knockback_dir": dir})


func input(event: InputEvent) -> void:
	# Change weapon.
	if event.is_action_pressed("weapon_prev"):
		character.previous_weapon()
	elif event.is_action_pressed("weapon_next"):
		character.next_weapon()


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


func calculate_rotation() -> float:
	var rotation:= character.global_rotation
	
	match global.input_type:
		global.INPUT_TYPES.KEY_MOUSE: # Keyboard and mouse input.
			var mouse_pos = character.get_global_mouse_position()
			var global_position = character.global_position
			if global_position.distance_to(mouse_pos) > MIN_DISTANCE_TO_CURSOR:
				rotation = global_position.direction_to(mouse_pos).angle()
		global.INPUT_TYPES.GAMEPAD: # Gamepad input.
			var aim_vector := Vector2(
				Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
				Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
			)
			if aim_vector.length() > .3:
				rotation = aim_vector.angle()
		_:
			pass #rotation = 
	return rotation
