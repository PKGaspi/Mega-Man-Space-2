extends "res://src/characters/enemies/enemy.gd"

var random : RandomNumberGenerator
	
func _ready() -> void:
	random = global.init_random()
	dir = Vector2(random.randf_range(-1, 1), random.randf_range(-1, 1)).normalized()
	
