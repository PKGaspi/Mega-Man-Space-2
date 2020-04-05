extends EnemyState


func _ready() -> void:
	yield(owner, "ready")
	
	var stats = character.stats
	stats.initialize()
	view_distance = stats.get_stat("view_distance")
	
	megaship = global.MEGASHIP


func physics_process(delta: float) -> void:
	if is_instance_valid(megaship):
		var distance_to_megaship = character.global_position.distance_to(megaship.global_position)
		if distance_to_megaship <= view_distance:
			_state_machine.restart()
