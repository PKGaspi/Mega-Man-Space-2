extends CharacterState



func enter(msg: Dictionary = {}) -> void:
	# Unpause.
	global.unpause()
	# Set pause mode back to inherit.
	character.pause_mode = Node.PAUSE_MODE_INHERIT
	
	# Go to the initial intended state.
	_state_machine.restart()
	
	# Fill hp bar.
	character.hp_bar.value = 0
	character.hp_bar.set_value(character.hp, true)
