extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
const MOTION_SPEED = 160 # Pixels/second

onready var camera = get_node("Camera2D")

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
	
	# Direction.
	var mouse_pos = get_global_mouse_position()
	rotation = (mouse_pos - global_position).rotated(deg2rad(90)).angle()
	
