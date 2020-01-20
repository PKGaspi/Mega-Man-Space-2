extends "res://src/characters/character.gd"

export (SpriteFrames) var masks
export (SpriteFrames) var palettes

export(float) var move_speed = 0
export(bool) var invert_dir = false
export(bool) var rotate_towards_destination = false
export(bool) var follow_megaship = false
export(float) var follow_max_distance = -1
export(bool) var dynamic_dir : bool = true
var to_follow = null
var to_follow_on_range = false
var dir : Vector2 = Vector2()
var destination : Vector2 = Vector2()
var motion : Vector2 = Vector2()

var drop = load("res://src/characters/pickups/pickup_randomizer.gd")
export(float) var drop_chance = .5

export(float) var damage = 4 # Collision damage.

func _ready():
	# Connect to_follow exit_tree signal
	if follow_megaship:
		follow_megaship()
	if to_follow != null:
		to_follow.connect("tree_exiting", self, "_on_to_follow_tree_exiting")
		
	
	destination = get_destination()
	if dynamic_dir:
		dir = global_position.direction_to(destination)
	if rotate_towards_destination:
		rotation = dir.angle() + PI / 2
func _physics_process(delta: float) -> void:
	destination = get_destination()
	if dynamic_dir:
		dir = global_position.direction_to(destination)
	if to_follow != null:
		to_follow_on_range = follow_max_distance < 0 or global_position.distance_to(destination) <= follow_max_distance
		if !to_follow_on_range:
			dir = Vector2()
	if invert_dir:
		dir = - dir
	if rotate_towards_destination and (to_follow_on_range or to_follow == null):
		rotation = dir.angle() + PI / 2
	motion = dir * move_speed * acceleration
	move_and_slide(motion)

func init(pos):
	global_position = pos

func _on_to_follow_tree_exiting():
	set_to_follow()

#########################
## Auxiliar functions. ##
#########################

func follow_megaship() -> void:
	set_to_follow(global.MEGASHIP)

func set_to_follow(value = null) -> void:
	to_follow = value
	dynamic_dir = value != null
	if to_follow is Node:
		to_follow.connect("tree_exiting", self, "_on_to_follow_tree_exiting")

func get_destination() -> Vector2:
	if to_follow is Vector2:
		return to_follow
	elif to_follow != null:
		return to_follow.global_position
	else:
		return destination
	

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
	collider.push(motion)
	collider.hit(damage)