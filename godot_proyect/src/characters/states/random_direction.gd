extends State

onready var rng := global.init_random()
onready var dir: Vector2 = random_dir()


func _ready() -> void:
	dir = random_dir()


func enter(msg: Dictionary = {"new_dir": false}) -> void:
	# Calculate velocity.
	if msg.has("new_dir") and msg["new_dir"]:
		dir = random_dir()


func physics_process(delta: float) -> void:
	# Move.
	_parent.velocity = dir * _parent.max_speed
	_parent.physics_process(delta)


func random_dir() -> Vector2:
	return Vector2.RIGHT.rotated(rng.randf_range(0, 2*PI))
