class_name WeaponState
extends State

export(Weapon.TYPES) var weapon
export var projectile: PackedScene

var cannons: Node
var ammo: float



func _ready() -> void:
	yield(owner, "ready")
	cannons = owner
	ammo = cannons.ammo


func enter(msg := {}) -> void:
	cannons.set_projectile(projectile)
	cannons.set_ammo(ammo)
