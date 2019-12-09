extends KinematicBody2D

# Constants.

# Resources.
const LEMON = preload("res://scenes/lemon.tscn")
onready var AUDIO = get_node("AudioStreamPlayer2D")
onready var LIB = get_node("/root/library")

# Moving speed.
const MOVE_SPEED_ACCEL = 30 # In pixels/second^2.
const MOVE_SPEED_DEACCEL = 50 # In pixels/second^2.
const MOVE_SPEED_MAX = 260 # In pixels/second.
# Cannons positions.
const CANNON_CENTRE_POS = Vector2(15, -.5)
const CANNON_LEFT_POS = Vector2(7, 4)
const CANNON_RIGHT_POS = Vector2(7, -5)
# Auto fire cooldown. Maybe do this a variable so
# you can get upgrades to improve it.
const AUTO_FIRE_INTERVAL = .05 # In seconds/bullet.

const JOYSTICK_DEADZONE = .1

var gamepad = false
var mouse_pos
var mouse_last_pos

# Upgrades and atributes.
# Speeds.
var speed_multiplier = 1 # This applies to max speed and accelerations.
# Bullets.
var n_shoots = 3 # Number of active cannons.
var bullet_max = 7 # Max bullets per cannon on screen.
var auto_fire = 0 # Seconds since last fire.

# Motion variables.
var speed = 0 # Speed at this frame.

var random

func _physics_process(delta):
	# Movement.
	var input = get_directional_input()
	var motion = get_motion(input)
	move_and_slide(motion)

func _process(delta):
	
	# Get new values of this frame.
	mouse_pos = get_viewport().get_mouse_position()
	
	# Calculate rotation.
	rotation = get_rotation()
	
	# Check if we are firing.
	auto_fire += delta
	if Input.is_action_pressed("shoot") and auto_fire >= AUTO_FIRE_INTERVAL:
		fire(n_shoots)
		auto_fire = 0
	
	# Check mouse mode.
	if gamepad:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	# Update values for next frame.
	mouse_last_pos = mouse_pos

func get_directional_input():
	
	var input = Vector2()
	var empty = Vector2()
	
	# Keyboard input.
	if Input.is_action_pressed("keyboard_move_up"):
		gamepad = false
		input += Vector2(0, -1)
	if Input.is_action_pressed("keyboard_move_down"):
		gamepad = false
		input += Vector2(0, 1)
	if Input.is_action_pressed("keyboard_move_left"):
		gamepad = false
		input += Vector2(-1, 0)
	if Input.is_action_pressed("keyboard_move_right"):
		gamepad = false
		input += Vector2(1, 0)
		
	# Gamepad input.
	if Input.is_action_pressed("gamepad_move_up"):
		gamepad = true
		input += Vector2(0, -1)
	if Input.is_action_pressed("gamepad_move_down"):
		gamepad = true
		input += Vector2(0, 1)
	if Input.is_action_pressed("gamepad_move_left"):
		gamepad = true
		input += Vector2(-1, 0)
	if Input.is_action_pressed("gamepad_move_right"):
		gamepad = true
		input += Vector2(1, 0)
	
	if input == empty:
		# Joystick input.
		input = get_joystick_axis(0, JOY_AXIS_0)
	
	return input

func get_rotation():
	var rot
	var input = get_joystick_axis(0, JOY_AXIS_3)
	
	if input != Vector2():
		gamepad = true
		rot = input.angle()
	else:
		rot = rotation
		if mouse_pos != mouse_last_pos:
			gamepad = false
	
	if !gamepad:
		if position.distance_to(mouse_pos) > 3:
			rot = mouse_pos.angle_to_point(get_global_transform_with_canvas().origin)
		else:
			rot = rotation
	
	return rot

func get_joystick_axis(device, joystick):
	var input = Vector2(Input.get_joy_axis(device, joystick), Input.get_joy_axis(device, joystick + 1))
	if input.length() < JOYSTICK_DEADZONE:
		input = Vector2()
	else:
		gamepad = true
	return input

func get_motion(input):
	if input != Vector2():
		# Accelerate.
		speed = clamp(speed + MOVE_SPEED_ACCEL, 0, MOVE_SPEED_MAX)
	else:
		# Deaccelerate.
		speed = clamp(speed - MOVE_SPEED_DEACCEL, 0, MOVE_SPEED_MAX)
	var motion = input.normalized() * speed * speed_multiplier
	return motion

func fire(ammount):
	var shooted = false
	if ammount % 2 == 1:
		shooted = shoot_projectile(LEMON, "BULLETS_CENTRE", CANNON_CENTRE_POS) or shooted
	if ammount >= 2:
		shooted = shoot_projectile(LEMON, "BULLETS_LEFT", CANNON_LEFT_POS) or shooted
		shooted = shoot_projectile(LEMON, "BULLETS_RIGHT", CANNON_RIGHT_POS) or shooted
		
	if shooted:
		# Play sound.
		LIB.play_audio_random_pitch(AUDIO, Vector2(.9, 1.1))

func shoot_projectile(projectile, group, pos):
	var shooted = get_tree().get_nodes_in_group(group).size() < bullet_max
	# Check if there are too many projectiles.
	if shooted:
		# Fire projectile.
		var inst = projectile.instance()
		inst.add_collision_exception_with(self)
		inst.rotation = rotation
		inst.global_position = global_position + pos.rotated(rotation)
		inst.add_to_group(group)
		get_parent().add_child(inst)
		
	return shooted
	
