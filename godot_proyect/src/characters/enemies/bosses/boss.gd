class_name Boss
extends Enemy


export(Weapon.TYPES) var palette: int

onready var propulsion_particles := $PropulsionParticles



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


func apply_propulsion_effects(propulsion: Vector2) -> void:
	propulsion_particles.emit(propulsion)


func die() -> void:
	# Generate death scene.
	var inst = death_instance.instance()
	inst.palette = palette
	inst.global_position = global_position
	get_parent().add_child(inst)
	
	queue_free()
	
