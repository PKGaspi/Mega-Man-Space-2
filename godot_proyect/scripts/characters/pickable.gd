extends "res://scripts/characters/enemy.gd"

var random : RandomNumberGenerator
	
func _ready() -> void:
	random = global.init_random()
	dir = Vector2(random.randf(), random.randf()).normalized()
	
