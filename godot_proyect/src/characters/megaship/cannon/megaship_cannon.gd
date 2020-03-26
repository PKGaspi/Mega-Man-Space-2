class_name MegashipCannons
extends Node2D

onready var snd_weapon_change = $SndWeaponSwap
onready var state_machine = $StateMachine

export var stats: Resource
export var _ammo_bar_path: NodePath
onready var ammo_bar = get_node(_ammo_bar_path)

var weapon: int = Weapon.TYPES.MEGA
var n_cannons: int = 1
var ammo: float
var max_ammo: float
var ammo_per_shot: float


var weapon_states := {
	Weapon.TYPES.MEGA: "RapidFire/Mega",
	Weapon.TYPES.AIR: "RapidFire/Air",
	Weapon.TYPES.BUBBLE: "RapidFire/Bubble",
	Weapon.TYPES.QUICK: "RapidFire/Quick",
	Weapon.TYPES.METAL: "RapidFire/Metal",
	Weapon.TYPES.CRASH: "RapidFire/Crash",
	Weapon.TYPES.HEAT: "ChargedFire/Heat",
	Weapon.TYPES.WOOD: "ChargedFire/Wood",
	Weapon.TYPES.FLASH: "Flash",
	Weapon.TYPES.ONE: "One",
	Weapon.TYPES.TWO: "Two",
	Weapon.TYPES.THREE: "Three",
}


signal weapon_changed(new_weapon)


func _ready() -> void:
	assert(stats != null and stats is StatsCannon)
	stats.initialize()
	
	n_cannons = stats.get_stat("n_cannons")
	max_ammo = stats.get_stat("max_ammo")
	ammo = max_ammo
	ammo_per_shot = stats.get_stat("ammo_per_shot")
	
	stats.connect("stat_changed", self, "_on_stat_changed")
	
	if ammo_bar != null:
		ammo_bar.visible = weapon != Weapon.TYPES.MEGA


func _on_stat_changed(stat_name: String, new_value: float) -> void:
	match stat_name:
		"n_cannons": n_cannons = new_value
		"max_bullets": set_max_projectiles(new_value)


func fire(power: int = 0) -> bool:
	assert(n_cannons > 0 and n_cannons <= get_child_count())
	var shooted := false
	if ammo > 0:
		shooted = get_child(n_cannons - 1).fire(power)
		if shooted:
			set_ammo_relative(-ammo_per_shot)
	return shooted


func weapon_to_state(weapon_index: int = weapon) -> String:
	assert(weapon_states.has(weapon))
	return weapon_states[weapon_index] if weapon_states.has(weapon_index) else "Disabled"


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
		if child is CannonSetup:
			child.set_max_projectiles(value)


func set_ammo(value: float, pause: bool = false) -> void:
	ammo = clamp(value, 0, max_ammo)
	if ammo_bar != null:
		ammo_bar.set_value(ammo, pause)


func set_ammo_relative(relative_value: float, pause: bool = false) -> void:
	set_ammo(ammo + relative_value, pause)


func set_weapon(value: int, play_sound := true) -> bool:
	# Clamp value.
	value = int(fposmod(value, Weapon.TYPES.size()))
	if weapon == value:
		# Weapon did not change cause this is the current weapon.
		return true 
	
	var unlocked = global.unlocked_weapons[value]
	
	if unlocked:
		# TODO: check if the weapon is unlocked.
		weapon = value
		state_machine.transition_to(weapon_to_state(weapon))
		if play_sound and snd_weapon_change != null:
			snd_weapon_change.play()
		
		if ammo_bar != null:
			ammo_bar.visible = weapon != Weapon.TYPES.MEGA
			ammo_bar.palette = weapon
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
