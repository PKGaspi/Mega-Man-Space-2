class_name Enemy
extends Character

export var drops: Resource

var collision_damage = 4


func _ready() -> void:
	drops.initialize()


func die() -> void:
	# Drop an item.
	drop()
	
	# Execute regular death.
	.die()

func drop() -> void:
	# Drop something.
	var to_drop = drops.get_random_item()
	if to_drop != null and to_drop is PackedScene:
		var inst = to_drop.instance()
		if inst is Node2D:
			inst.global_position = global_position
		add_child(inst)
