class_name WeaponState
extends CannonState

export var projectile: PackedScene

# Stats.
export var stats: Resource

var weapon: int
var ammo: float
var ammo_per_shot: float


func _ready() -> void:
	yield(owner, "ready")
	
	# Setup stats.
	stats.initialize()
	weapon = stats.get_stat("weapon")
	ammo = cannons.ammo
	ammo_per_shot = stats.get_stat("ammo_per_shot")


func enter(msg := {}) -> void:
	cannons.set_projectile(projectile)
	cannons.set_ammo(ammo)
	cannons.ammo_per_shot = ammo_per_shot
