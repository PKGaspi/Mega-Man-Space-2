extends "res://scripts/character.gd"

const UPGRADE = preload("res://scenes/upgrade.tscn")
const UPGRADE_CHANCE = .2

func _ready():
	snd_hit = $"../SndHit" # The hit sound is played by the parent.

func init(pos):
	global_position = pos

#########################
## Auxiliar functions. ##
#########################

func die():
	# Tell the enemy generator I died.
	get_parent().count_death()
	# Generate an upgrade at random.
	if randf() <= UPGRADE_CHANCE:
		var inst = UPGRADE.instance()
		inst.global_position = global_position
		get_parent().add_child(inst)
	# Destroy myself.
	queue_free()
	
