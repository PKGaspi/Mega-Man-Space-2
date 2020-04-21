extends Bullet


const MINI_BULLET := preload("res://src/characters/enemies/bosses/heat_man/heat_man_mini_bullet.tscn")
const N_MINI_BULLETS := 5

onready var cannons := $CannonSetup

func disappear() -> void:
	# Create mini bullets when exploding.
	cannons.fire()
	.disappear()
