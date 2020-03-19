class_name WeaponState
extends CharacterState

export(Weapon.TYPES) var weapon
export var projectile: PackedScene

export var _cannons_path: NodePath
var cannons: Node
var ammo = 28

func _ready() -> void:
	yield(owner, "ready")
	cannons = get_node(_cannons_path)


func physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		cannons.fire()


func enter(msg := {}) -> void:
	character.set_palette(weapon)
	cannons.set_projectile(projectile)
	cannons.set_ammo(ammo)
	cannons.set_weapon(weapon)
