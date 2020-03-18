class_name CannonUpgrader
extends Node2D

export var n_cannons: int = 1

func fire() -> bool:
	if n_cannons > 0 and n_cannons <= get_child_count():
		return get_child(n_cannons - 1).fire()
	return false

# Setters act on all childs.
func set_cooldown(value: float) -> void:
	for child in get_children():
		if child is CannonSetup:
			child.set_cooldown(value)


func set_projectile(value: PackedScene) -> void:
	for child in get_children():
		if child is CannonSetup:
			child.set_projectile(value)


func set_max_projectiles(value: int) -> void:
	for child in get_children():
		if child is Cannon:
			child.set_max_projectiles(value)
