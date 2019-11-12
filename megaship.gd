extends KinematicBody2D

# Constants.
const MOVE_SPEED = 160 # In pixels/second.
const CANNON_LEFT_POS = Vector2(15, 9)
const CANNON_RIGHT_POS = Vector2(15, -9)
const AUTO_FIRE_INTERVAL = .05 # In seconds/bullet.

const LEMON = preload("res://lemon.tscn")

var speed_multiplier = 1
var bullet_max = 3
var auto_fire = 0

func _physics_process(_delta):
	# Movement.
	var motion = Vector2()
	
	if Input.is_action_pressed("move_up"):
		motion += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		motion += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		motion += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		motion += Vector2(1, 0)
	
	motion = motion.normalized() * MOVE_SPEED * speed_multiplier
	move_and_slide(motion)
	
func _process(delta):
	# Calculate direction to look at the mouse.
	var mouse_pos = get_global_mouse_position()
	rotation = mouse_pos.angle_to_point(global_position)
	
	auto_fire += delta
	
	if Input.is_action_just_pressed("shoot"):
		fire()
	if Input.is_action_pressed("auto_shoot") and auto_fire >= AUTO_FIRE_INTERVAL:
		fire()
		auto_fire = 0
	

func fire():
	# Check if there are too many lemons.
	if get_tree().get_nodes_in_group("BULLETS_LEFT").size() < bullet_max:
		# Fire left lemon.
		var lem_l = LEMON.instance()
		lem_l.add_collision_exception_with(self)
		lem_l.rotation = rotation
		lem_l.global_position = global_position + CANNON_LEFT_POS.rotated(rotation)
		lem_l.add_to_group("BULLETS_LEFT")
		get_parent().add_child(lem_l)
	
	if get_tree().get_nodes_in_group("BULLETS_RIGHT").size() < bullet_max:
		var lem_r = LEMON.instance()
		lem_r.add_collision_exception_with(self)
		lem_r.rotation = rotation
		lem_r.global_position = global_position + CANNON_RIGHT_POS.rotated(rotation)
		lem_r.add_to_group("BULLETS_RIGHT")
		get_parent().add_child(lem_r)