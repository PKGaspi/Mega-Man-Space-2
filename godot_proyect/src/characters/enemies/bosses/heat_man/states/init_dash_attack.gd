extends EnemyState



func enter(msg: Dictionary = {}) -> void:
	var path: Array
	path.resize(4)
	
	var dir = direction_to_megaship()
	
	path[0] = character.global_position + dir.rotated(PI/6) * 100
	path[1] = path[0] + dir.rotated(-PI/4) * 200
	path[2] = path[1] + dir.rotated(PI/2) * 200
	path[3] = path[2] + dir * 200
	
	_state_machine.transition_to("Move/Dash", {"path": path})
