extends EnemyState





func physics_process(delta: float) -> void:
	# Move.
	_parent.velocity = _parent.calculate_velocity(Vector2.ZERO, delta)
	_parent.physics_process(delta)
	
	if is_instance_valid(megaship):
		var distance_to_megaship = character.global_position.distance_to(megaship.global_position)
		if distance_to_megaship < view_distance:
			_state_machine.transition_to("Move/Follow/Megaship")
