class_name Enemy
extends Character

export (SpriteFrames) var masks
export (SpriteFrames) var palettes

export(float) var move_speed = 0
export(bool) var invert_dir = false
export(bool) var rotate_towards_destination = false
export(bool) var _follow_megaship_at_ready = false
export(float) var follow_max_distance = -1
export(bool) var dynamic_dir : bool = true
export(float, .0, 1.0) var drifting: = .0 # How easily this enemi drifts.

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
	if to_follow != null:
		set_to_follow(to_follow)
	elif _follow_megaship_at_ready:
		follow_megaship()
		
	
	destination = get_destination()
	if dynamic_dir:
		dir = global_position.direction_to(destination)
	if invert_dir:
		dir = - dir
	if rotate_towards_destination:
		rotation = dir.angle() + PI / 2

func _physics_process(delta: float) -> void:
	destination = get_destination()
	if dynamic_dir:
		if dir == Vector2.ZERO:
			dir = global_position.direction_to(destination)
		else:
			if invert_dir:
				dir = - dir # Dir needs to be inverted if it was before.
			var rot = dir.angle_to(global_position.direction_to(destination))
			rot *= (1 - drifting) / 10
			dir = dir.rotated(rot)
	if to_follow != null:
		to_follow_on_range = follow_max_distance < 0 or global_position.distance_to(destination) <= follow_max_distance
		if !to_follow_on_range:
			dir = Vector2.ZERO
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
	if to_follow is Node2D and to_follow.is_connected("tree_exiting", self, "_on_to_follow_tree_exiting"):
		to_follow.disconnect("tree_exiting", self, "_on_to_follow_tree_exiting")
	to_follow = value
	dynamic_dir = value != null
	if to_follow is Node2D:
		to_follow.connect("tree_exiting", self, "_on_to_follow_tree_exiting")

func get_destination() -> Vector2:
	if to_follow is Vector2:
		return to_follow
	elif to_follow != null and to_follow is Node2D:
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
	collider.hit(damage)
