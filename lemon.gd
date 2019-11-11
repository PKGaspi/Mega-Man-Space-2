extends KinematicBody2D

const MOTION_SPEED = 320 # Pixels/second.

func _ready():
	add_collision_exception_with(self)
	get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")

func _on_screen_exited():
	# Destroy itself if it has exited the screen.
	queue_free()


func _physics_process(delta):
	var motion = Vector2(cos(rotation), sin(rotation)) * MOTION_SPEED
	move_and_slide(motion)
	
	if get_slide_count() != 0:
		# TODO: take damage on the collided node.
		# Destroy itself if it has exited the screen.
		queue_free()