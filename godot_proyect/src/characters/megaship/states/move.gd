extends CharacterState

const MIN_DISTANCE_TO_CURSOR = 5

# Speed and acceleration.

const MIN_MAX_SPEED:= 200.0
export var max_speed:= 260.0 setget set_max_speed
const MAX_MAX_SPEED:= 400.0
export var acceleration_ratio:= 7/4
var current_velocity:= Vector2.ZERO



func physics_process(delta):
	# Movement.
	var input_dir = get_input_direction()
	var acceleration = acceleration_ratio * max_speed
	var velocity = calculate_velocity(input_dir, acceleration, delta)
	character.move_and_slide(velocity)
	# Check for collision.
	for i in range(character.get_slide_count()):
		var collider = character.get_slide_collision(i).collider
		if collider is Character:
			collider.collide(character)
			break
	# Calculate rotation and sprite.
	character.rotation = calculate_rotation()
	
	# Emit propulsion particles.
	var propulsion = input_dir.normalized() * acceleration
	character.apply_propulsion_effects(propulsion)


func input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_prev"):
		character.previous_weapon()
	elif event.is_action_pressed("weapon_next"):
		character.next_weapon()

# Methods to move to here:
# new: get_character_collision.
# get_rotation -> calculate_rotation
# 

## Setters and getters. ##

func set_max_speed(value: float) -> void:
	max_speed = clamp(value, MIN_MAX_SPEED, MAX_MAX_SPEED)
	print(max_speed)

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
	delta: float
) -> Vector2:
	
	var new_velocity: Vector2 
	if move_direction != Vector2.ZERO:
		# Accelerate.
		new_velocity = move_direction * acceleration * delta + current_velocity
	else:
		# Deaccelerate.
		new_velocity = current_velocity - current_velocity.normalized() * (acceleration * 4 / 5) * delta
	
	if new_velocity.length() > max_speed:
		new_velocity = new_velocity.normalized() * max_speed
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

