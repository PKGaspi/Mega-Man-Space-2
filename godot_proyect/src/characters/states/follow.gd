extends MoveableState

var to_follow: Vector2
var distance: float


func enter(msg: Dictionary = {}) -> void:
	assert(msg.has("to_follow"))
	to_follow = msg["to_follow"]


func physics_process(delta: float) -> void:
	# Calculate movement.
	var dir = moveable.global_position.direction_to(to_follow)
	var acceleration = _parent.acceleration_ratio * _parent.max_speed
	_parent.velocity = _parent.calculate_velocity(dir, acceleration, _parent.velocity, delta)
	
	# Call the parent state's method to apply movement.
	_parent.physics_process(delta)
	
