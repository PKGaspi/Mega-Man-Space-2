class_name EnemyState
extends CharacterState


var megaship

func _ready() -> void:
	yield(owner, "ready")
	
	megaship = global.MEGASHIP


func direction_to_megaship() -> Vector2:
	var dir := Vector2.ZERO
	if is_instance_valid(megaship):
		dir = character.global_position.direction_to(megaship.global_position)
	return dir

func distance_to_megaship() -> float:
	var distance := 0.0
	if is_instance_valid(megaship):
		distance = character.global_position.distance_to(megaship.global_position)
	return distance


func megaship_in_view_distance() -> bool:
	return distance_to_megaship() <= view_distance and is_instance_valid(megaship)


func rotate_towards_megaship() -> void:
	character.global_rotation = direction_to_megaship().rotated(PI/2).angle()
