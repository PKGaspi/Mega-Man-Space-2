extends "res://src/characters/enemies/enemy.gd"

var random : RandomNumberGenerator = global.init_random()

export (String) var type : String # Which stat to change.
export (float) var ammount : float # The ammount to change.

func _ready() -> void:
	# Set random direction.
	dir = Vector2(random.randf_range(-1, 1), random.randf_range(-1, 1)).normalized()

	print(dir)
	print(dynamic_dir)