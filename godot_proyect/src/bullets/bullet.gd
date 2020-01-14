extends Area2D

export(float) var motion_speed = 560 # Pixels/second.

export(float) var damage : float = 2
var weapon : int = global.WEAPONS.MEGA

var dir

func _ready():
	dir = Vector2(cos(rotation), sin(rotation))

func _physics_process(delta):
	move(motion_speed * delta * dir)

func _on_screen_exited():
	# Destroy itself if it has exited the screen.
	queue_free()

func _on_body_entered(body: PhysicsBody2D) -> void:
	collide(body)

func init(global_position, rotation, group):
	self.global_position = global_position
	self.rotation = rotation
	add_to_group(group)

#########################
## Auxiliar functions. ##
#########################

func move(to_move):
	global_position += to_move

func collide(character) -> void:
	character.hit(damage, weapon)
	queue_free()