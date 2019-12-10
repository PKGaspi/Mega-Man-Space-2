extends KinematicBody2D

const MOTION_SPEED = 560 # Pixels/second.

var damage = 10

func _ready():
	add_collision_exception_with(self)
	var err = get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")
	if err != OK:
		print("Error connecting signal")

func _on_screen_exited():
	# Destroy itself if it has exited the screen.
	queue_free()


func _physics_process(delta):
	var motion = Vector2(cos(rotation), sin(rotation)) * MOTION_SPEED
	var collision = move_and_collide(motion * delta)
	
	if collision and collision.collider.is_in_group("ENEMIES"):
		# TODO: take damage on the collided node.
		# Destroy itself if it has exited the screen.
		collision.collider.hit(self)
		queue_free()