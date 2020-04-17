extends EnemyState


func _ready() -> void:
	pass


func enter(msg: Dictionary = {}) -> void:
	# TODO: Calculate init position and path to follow.
	
	_state_machine.transition_to("EndSpawnAnimation")
