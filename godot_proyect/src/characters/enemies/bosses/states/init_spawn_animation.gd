extends CharacterState



func enter(msg: Dictionary = {}) -> void:
	character.hp_bar.value = 0
	character.collision_box.disabled = true
	# Pause the rest of the game.
	character.pause_mode = Node.PAUSE_MODE_PROCESS
	global.pause()
	
	# Go to the moving state of the animation.
	_state_machine.transition_to("Move/Follow/SpawnAnimation")
