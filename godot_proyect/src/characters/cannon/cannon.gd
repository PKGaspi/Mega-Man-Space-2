class_name Cannon
extends Position2D

export var projectile: PackedScene setget set_projectile# What to shoot.


func fire(power: int = 0) -> bool:
	
	var inst = projectile.instance()
	inst.power = power
	inst.global_position = global_position
	inst.global_rotation = global_rotation - PI / 2
	
	ObjectRegistry.register_projectile(inst)
	
	return true


func set_projectile(value: PackedScene) -> void:
	projectile = value
