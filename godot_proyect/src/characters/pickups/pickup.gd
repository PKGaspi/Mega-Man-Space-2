extends "res://src/characters/enemies/enemy.gd"

var random : RandomNumberGenerator = global.init_random()

export (String) var type : String # Which stat to change.
export (float) var ammount : float # The ammount to change.
var bad : bool = ammount < 0 # Whether the pickpup is bad or good.

func _ready() -> void:
	# Set random direction.
	dir = Vector2(random.randf_range(-1, 1), random.randf_range(-1, 1)).normalized()
	


func collide(collider):
	collider.upgrade(type, ammount)
	if bad:
		.collide(collider)
	disappear()
