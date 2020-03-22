class_name Bullet
extends Area2D

export(float, 0, 1000, 10) var motion_speed = 560 # Pixels/second.
export(float, 0, 30, .1) var damage : float = 2
export(Weapon.TYPES) var weapon = Weapon.TYPES.MEGA
export(int) var n_collisions = 1 # Number of collisions before the bullet dissapears. Cero or negative for no max.

var power
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
	n_collisions -= 1
	if n_collisions == 0:
		disconnect("body_entered", self, "_on_body_entered")
		queue_free()
