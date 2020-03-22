class_name Cannon
extends Position2D

export var projectile: PackedScene setget set_projectile# What to shoot.
export var max_projectiles: int = 3 # Max number of projectiles at once on the screen.
export var cooldown: float = .1 setget set_cooldown# Time between shoots.

onready var _cooldown_timer := $Cooldown
var n_projectiles: int = 0 # Current number of projectiles on screen.


func _on_projectile_tree_exiting() -> void:
	n_projectiles -= 1


func fire(power: int = 0) -> bool:
	if n_projectiles >= max_projectiles or not _cooldown_timer.is_stopped():
		return false
		
	var inst = projectile.instance()
	inst.power = power
	inst.global_position = global_position
	inst.global_rotation = global_rotation
	inst.connect("tree_exited", self, "_on_projectile_tree_exiting")
	
	ObjectRegistry.register_projectile(inst)
	n_projectiles += 1
	
	_cooldown_timer.start()
	
	return true


func set_cooldown(value: float) -> void:
	cooldown = value
	_cooldown_timer.wait_time = value


func set_projectile(value: PackedScene) -> void:
	projectile = value


func set_max_projectiles(value: int) -> void:
	max_projectiles = value
