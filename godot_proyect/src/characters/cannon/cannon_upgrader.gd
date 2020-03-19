class_name MegashipCannons
extends Node2D

export var stats: Resource
export var _ammo_bar_path: NodePath
onready var ammo_bar = get_node(_ammo_bar_path)

var n_cannons: int = 1
var ammo
var max_ammo
var ammo_per_shot

func _ready() -> void:
	assert(stats != null and stats is CannonStats)
	stats.initialize()
	n_cannons = stats.get_stat("n_cannons")
	max_ammo = stats.get_stat("max_ammo")
	ammo = max_ammo
	ammo_per_shot = stats.get_stat("ammo_per_shot")


func fire() -> bool:
	assert(n_cannons > 0 and n_cannons <= get_child_count())
	var shooted := false
	if ammo > 0:
		shooted = get_child(n_cannons - 1).fire()
		if shooted:
			set_relative_ammo(-ammo_per_shot)
	return shooted

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


func set_ammo(value: float, pause: bool = false) -> void:
	ammo = clamp(value, 0, max_ammo)
	if ammo_bar != null:
		ammo_bar.set_value(ammo, pause)

func set_relative_ammo(relative_value: float, pause: bool = false) -> void:
	set_ammo(ammo + relative_value, pause)
