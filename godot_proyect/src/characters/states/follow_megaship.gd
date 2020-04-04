extends EnemyState


func physics_process(delta: float) -> void:
	# Move.
	var distance_to_megaship
	if is_instance_valid(megaship):
		_parent.to_follow = megaship.global_position
		distance_to_megaship = character.global_position.distance_to(megaship.global_position)
	_parent.physics_process(delta)
	
	# Check State changing.
	if !is_instance_valid(megaship) or distance_to_megaship > view_distance:
		_state_machine.transition_to("Move/Deaccelerate")


func _on_megaship_tree_exited() -> void:
	megaship = null
	
