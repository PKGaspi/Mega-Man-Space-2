extends Node

onready var _projectiles:= $Projectiles

func register_projectile(projectile: Node) -> void:
	_projectiles.add_child(projectile)
