extends "res://scripts/characters/character.gd"

var UPGRADE = load("res://scenes/characters/upgrade.tscn")
const UPGRADE_CHANCE = .2

func _ready():
	pass
	#snd_hit = $"../SndHit" # The hit sound is played by the parent.

func init(pos):
	global_position = pos

#########################
## Auxiliar functions. ##
#########################

func die():
	# Tell the enemy generator I died.
	if get_parent().has_method("count_death"):
		get_parent().count_death()
	# Generate an upgrade at random.
	if randf() <= UPGRADE_CHANCE:
		var inst = UPGRADE.instance()
		inst.global_position = global_position
		get_parent().add_child(inst)
	# Super method.
	.die()
	
