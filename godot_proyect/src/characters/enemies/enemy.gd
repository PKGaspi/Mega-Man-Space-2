extends "res://src/characters/character.gd"

export (SpriteFrames) var masks
export (SpriteFrames) var palettes

export(float) var move_speed = 0
export(bool) var follow_megaship = false
export(float) var follow_max_distance = -1
var to_follow : Node2D = null
var dir : Vector2 = Vector2()

var drop = load("res://src/characters/pickups/pickup_randomizer.gd")
export(float) var drop_chance = .5

export(float) var damage = 4 # Collision damage.

func _ready():
	
	# Connect to_follow exit_tree signal
	if follow_megaship:
		to_follow = global.MEGASHIP
	if to_follow != null:
		to_follow.connect("tree_exiting", self, "_on_to_follow_tree_exiting")
	
func _physics_process(delta: float) -> void:
	if to_follow != null:
		if follow_max_distance < 0 or global_position.distance_to(to_follow.global_position) <= follow_max_distance:
			dir = global_position.direction_to(to_follow.global_position)
		else:
			dir = Vector2()
	var motion = dir * move_speed
	move_and_slide(motion)

func init(pos):
	global_position = pos

func _on_to_follow_tree_exiting():
	to_follow = null

#########################
## Auxiliar functions. ##
#########################

func die():
	# Generate an upgrade at random.
	if randf() <= drop_chance:
		var inst = drop.new()
		inst.global_position = global_position
		get_parent().call_deferred("add_child", inst)
	# Super method.
	.die()
	

func collide(collider):
	# Default action on collide.
	collider.hit(damage)