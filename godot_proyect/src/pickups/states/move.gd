extends MoveableState

var stats: Resource

var max_speed: float
var velocity := Vector2.ZERO


func _ready() -> void:
	yield(owner, "ready")
	stats = moveable.stats
	
	max_speed = stats.get_stats("max_speed")


func physics_process(delta: float) -> void:
	moveable.move(velocity * delta)
