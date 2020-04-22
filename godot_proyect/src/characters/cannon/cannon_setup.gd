class_name CannonSetup
extends Node2D

onready var snd_shoot := $SndShoot
onready var snd_charge := $SndCharge


func fire(power: int = 0) -> bool:
	# Called when there is an attempt to shoot. This method checks that a
	# shoot is viable and if so creates the projectiles via shoot_projectile().
	var shooted = false
	for child in get_children():
		if child is Cannon:
			shooted = child.fire(power) or shooted # If any cannon shooted, return true and act as so.
	if shooted:
		snd_shoot.play() # Play sound.
	return shooted


func set_projectile(value: PackedScene) -> void:
	for child in get_children():
		if child is Cannon:
			child.set_projectile(value)

