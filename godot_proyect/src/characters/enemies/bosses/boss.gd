class_name Boss
extends Enemy


func _ready() -> void:
	pass


func _on_boss_music_intro_finished() -> void:
	if not is_instance_valid(_state_machine):
		call_deferred("start_spawn_animation")
		return
	_state_machine.transition_to("EndSpawnAnimation")


func start_spawn_animation() -> void:
	if not is_instance_valid(_state_machine):
		call_deferred("start_spawn_animation")
		return
	_state_machine.transition_to("InitSpawnAnimation")
