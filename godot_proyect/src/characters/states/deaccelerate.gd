extends EnemyState





func physics_process(delta: float) -> void:
	# Move.
	_parent.velocity = _parent.calculate_velocity(Vector2.ZERO, delta)
	_parent.physics_process(delta)
	
	if megaship_in_view_distance():
		_state_machine.restart()
