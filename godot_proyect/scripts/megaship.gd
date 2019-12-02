extends KinematicBody2D

# Constants.
const MOVE_SPEED_ACCEL = 30 # In pixels/second^2.
const MOVE_SPEED_DEACCEL = 50 # In pixels/second^2.
const MOVE_SPEED_MAX = 160 # In pixels/second.
const CANNON_LEFT_POS = Vector2(15, 9)
const CANNON_RIGHT_POS = Vector2(15, -9)
const AUTO_FIRE_INTERVAL = .05 # In seconds/bullet.

const LEMON = preload("res://scenes/lemon.tscn")

var speed = 0
var speed_multiplier = 1
var bullet_max = 3
var auto_fire = 0
var motion = Vector2()

func _physics_process(_delta):
	# Movement.
	var input = Vector2()
	if Input.is_action_pressed("move_up"):
		input += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		input += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		input += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		input += Vector2(1, 0)
	
	if input != Vector2():
		motion = input
		speed = clamp(speed + MOVE_SPEED_ACCEL, 0, MOVE_SPEED_MAX) * speed_multiplier
	else:
		speed = clamp(speed - MOVE_SPEED_DEACCEL, 0, MOVE_SPEED_MAX)
	motion = motion.normalized() * speed
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
	# Check if there are too many left lemons.
	if get_tree().get_nodes_in_group("BULLETS_LEFT").size() < bullet_max:
		# Fire left lemon.
		var lem_l = LEMON.instance()
		lem_l.add_collision_exception_with(self)
		lem_l.rotation = rotation
		lem_l.global_position = global_position + CANNON_LEFT_POS.rotated(rotation)
		lem_l.add_to_group("BULLETS_LEFT")
		get_parent().add_child(lem_l)
	
	# Check if there are too many right lemons.
	if get_tree().get_nodes_in_group("BULLETS_RIGHT").size() < bullet_max:
		# Fire right lemon.
		var lem_r = LEMON.instance()
		lem_r.add_collision_exception_with(self)
		lem_r.rotation = rotation
		lem_r.global_position = global_position + CANNON_RIGHT_POS.rotated(rotation)
		lem_r.add_to_group("BULLETS_RIGHT")
		get_parent().add_child(lem_r)