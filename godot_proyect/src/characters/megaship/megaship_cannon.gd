class_name MegashipCannons
extends Node2D

onready var snd_weapon_change = $SndWeaponSwap

export var stats: Resource
export var _ammo_bar_path: NodePath
onready var ammo_bar = get_node(_ammo_bar_path)

var weapon: int = Weapon.TYPES.MEGA
var n_cannons: int = 1
var ammo: float
var max_ammo: float
var ammo_per_shot: float

signal weapon_changed(new_weapon)


func _ready() -> void:
	assert(stats != null and stats is StatsCannon)
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


# Some setters act on all childs.
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


func set_weapon(value: int) -> bool:
	# Clamp value.
	value = int(fposmod(value, Weapon.TYPES.size()))
	if weapon == value:
		# Weapon did not change cause this is the current weapon.
		return true 
	
	var unlocked = global.unlocked_weapons[value]
	
	if unlocked:
		# TODO: check if the weapon is unlocked.
		if snd_weapon_change != null:
			snd_weapon_change.play()
		weapon = value
		if ammo_bar != null:
			ammo_bar.palette = weapon
			ammo_bar.visible = weapon != Weapon.TYPES.MEGA
		emit_signal("weapon_changed", weapon)
	
	return unlocked


func next_weapon() -> void:
	var new_weapon = weapon + 1
	while !set_weapon(new_weapon):
		new_weapon = new_weapon + 1


func previous_weapon() -> void:
	var new_weapon = weapon - 1
	while !set_weapon(new_weapon):
		new_weapon = new_weapon - 1
