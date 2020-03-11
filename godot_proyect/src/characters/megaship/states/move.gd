extends CharacterState


func physics_process(delta):
	# Movement.
	character.input_dir = character.get_directional_input()
	character.motion = character.get_motion(character.input_dir)
	character.move_and_slide(character.motion)
	# Check for collision.
	for i in range(character.get_slide_count()):
		var collider = character.get_slide_collision(i).collider
		if collider is Character:
			collider.collide(self)
			break
	# Calculate rotation and sprite.
	character.rotation = character.get_rotation()
	
	# Check if we are firing.
	if Input.is_action_pressed("shoot"):
		character.fire(character.n_cannons, character.ammo_per_shot[character.active_weapon])
	
	# Emit propulsion particles.
	character.emit_propulsion_particles(character.speed)

func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_prev"):
		character.previous_weapon()
	elif event.is_action_pressed("weapon_next"):
		character.next_weapon()
