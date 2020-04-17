class_name Boss
extends Enemy


func _ready() -> void:
	pass


func start_spawn_animation() -> void:
	_state_machine.transition_to("InitSpawnAnimation")
