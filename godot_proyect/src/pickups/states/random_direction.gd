extends State

onready var dir: Vector2
onready var rng := global.init_random()



func _ready() -> void:
	dir = random_dir()


func enter(msg: Dictionary = {}) -> void:
	# Calculate velocity.
	_parent.velocity = dir * _parent.max_speed


func physics_process(delta: float) -> void:
	# Move.
	_parent.physics_process(delta)


func random_dir() -> Vector2:
	return Vector2.RIGHT.rotated(rng.randf_range(0, 2*PI))
