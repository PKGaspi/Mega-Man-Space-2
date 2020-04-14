class_name WeaponState
extends CannonState

export var projectile: PackedScene

# Stats.
export var weapon_stats: Resource

var weapon: int
var ammo: float
var ammo_per_shot: float


func _ready() -> void:
	yield(owner, "ready")
	
	# Setup stats.
	weapon_stats.initialize()
	weapon = weapon_stats.get_stat("weapon")
	ammo = cannons.ammo
	ammo_per_shot = weapon_stats.get_stat("ammo_per_shot")


func enter(msg := {}) -> void:
	cannons.set_projectile(projectile)
	cannons.set_ammo(ammo)
	cannons.ammo_per_shot = ammo_per_shot


func exit() -> void:
	ammo = cannons.ammo
