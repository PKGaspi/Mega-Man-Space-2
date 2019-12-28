extends "res://scripts/characters/character.gd"

export(float) var move_speed = 0

export(PackedScene) var drop = load("res://scenes/characters/upgrade.tscn")
export(float) var upgrade_chance = .2

export(float) var damage = 4 # Collision damage.

var to_follow : Node2D = null
var dir : Vector2 = Vector2()

func _ready():
	pass
	#snd_hit = $"../SndHit" # The hit sound is played by the parent.
	
func _physics_process(delta: float) -> void:
	if to_follow != null:
		dir = global_position.direction_to(to_follow.global_position)
	var motion = dir * move_speed
	move_and_slide(motion)
	
	# Check for Mega Ship collision.
	for i in range(get_slide_count()):
		var collider = get_slide_collision(i).collider
		if collider == global.MEGASHIP:
			collide(collider)
			break

func init(pos):
	global_position = pos

#########################
## Auxiliar functions. ##
#########################

func die():
	# Generate an upgrade at random.
	if randf() <= upgrade_chance:
		var inst = drop.instance()
		inst.global_position = global_position
		get_parent().add_child(inst)
	# Super method.
	.die()
	

func collide(collider):
	# Default action on collide.
	collider.hit(self)