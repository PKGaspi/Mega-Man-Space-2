class_name PropulsionParticles
extends Node2D
# Handler for propulsion particle effects. All childs of this node should be
# Particle2D nodes.



func emit(propulsion: Vector2) -> void:
	var propulsion_dir = -propulsion
	var speed = propulsion.length()
	
	for child in get_children():
		if child is Particles2D:
			child.emitting = speed != 0
			child.global_rotation = propulsion_dir.angle()
			child.process_material.initial_velocity = speed / 4


func set_color(child_index, value) -> void:
	if child_index < get_child_count():
		var child = get_child(child_index)
		if child is Particles2D and child.process_material != null:
			child.process_material.color = value
