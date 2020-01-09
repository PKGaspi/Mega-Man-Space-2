extends Area2D

const MOTION_SPEED = 560 # Pixels/second.

var damage = 2

var dir

func _ready():
	dir = Vector2(cos(rotation), sin(rotation))
	var err = get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")
	if err != OK:
		print("Error connecting signal")

func _on_screen_exited():
	# Destroy itself if it has exited the screen.
	queue_free()


func _physics_process(delta):
	move(MOTION_SPEED * delta * dir)


func init(global_position, rotation, group):
	self.global_position = global_position
	self.rotation = rotation
	add_to_group(group)

func move(to_move):
	global_position += to_move

func _on_body_entered(body: PhysicsBody2D) -> void:
	body.hit(self)
	queue_free()