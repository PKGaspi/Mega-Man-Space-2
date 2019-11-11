extends KinematicBody2D

# Constants.
const MOTION_SPEED = 500 # Pixels/second.
const CANNON_LEFT_POS = Vector2(15, 9)
const CANNON_RIGHT_POS = Vector2(15, -9)

const LEMON = preload("res://lemon.tscn")

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
	
	motion = motion.normalized() * MOTION_SPEED
	move_and_slide(motion)
	
func _process(delta):
	# Calculate direction to look at the mouse.
	var mouse_pos = get_global_mouse_position()
	rotation = mouse_pos.angle_to_point(global_position)
	
	if Input.is_action_just_pressed("shoot"):
		fire()
	if Input.is_action_pressed("auto_shoot"):
		fire()

func fire():
	# Fire left lemon.
	var lem_l = LEMON.instance()
	lem_l.add_collision_exception_with(self)
	lem_l.rotation = rotation
	lem_l.global_position = global_position + CANNON_LEFT_POS.rotated(rotation)
	get_parent().add_child(lem_l)
	
	var lem_r = LEMON.instance()
	lem_r.add_collision_exception_with(self)
	lem_r.rotation = rotation
	lem_r.global_position = global_position + CANNON_RIGHT_POS.rotated(rotation)
	get_parent().add_child(lem_r)