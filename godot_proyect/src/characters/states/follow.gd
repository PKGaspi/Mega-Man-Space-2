extends MoveableState

var to_follow: Vector2
var dir: Vector2


func enter(msg: Dictionary = {}) -> void:
	assert(msg.has("to_follow"))
	to_follow = msg["to_follow"]
	dir = moveable.global_position.direction_to(to_follow)


func physics_process(delta: float) -> void:
	# Calculate movement.
	dir = moveable.global_position.direction_to(to_follow)
	_parent.velocity = _parent.calculate_velocity(dir, delta)
	
	# Call the parent state's method to apply movement.
	_parent.physics_process(delta)
	
