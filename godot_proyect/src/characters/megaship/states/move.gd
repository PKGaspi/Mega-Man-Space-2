extends CharacterState

export var max_speed:= 260.0
export var acceleration:= 120.0
export var deacceleration:= 60.0
var current_velocity:= Vector2.ZERO



func physics_process(delta):
	# Movement.
	var input_dir = get_input_direction()
	var velocity = calculate_velocity(input_dir, delta)
	character.move_and_slide(velocity)
	# Check for collision.
	for i in range(character.get_slide_count()):
		var collider = character.get_slide_collision(i).collider
		if collider is Character:
			collider.collide(character)
			break
	# Calculate rotation and sprite.
	character.rotation = character.get_rotation()
	
	# Check if we are firing.
	if Input.is_action_pressed("shoot"):
		character.fire()
	
	# Emit propulsion particles.
	character.emit_propulsion_particles(velocity.length())


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_prev"):
		character.previous_weapon()
	elif event.is_action_pressed("weapon_next"):
		character.next_weapon()

# Methods to move to here:
# new: get_character_collision.
# get_rotation -> calculate_rotation
# 


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
	delta: float
) -> Vector2:
	
	var new_velocity: Vector2 = move_direction * acceleration * delta + current_velocity

	if new_velocity.length() > max_speed:
		new_velocity = new_velocity.normalized() * max_speed
	# TODO: Implement deacceleration.
	current_velocity = new_velocity
	return new_velocity
