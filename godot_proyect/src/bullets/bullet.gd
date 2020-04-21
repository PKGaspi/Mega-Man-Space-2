class_name Bullet
extends KinematicBody2D

export(float, 0, 1000, 10) var motion_speed: float = 560 # Pixels/second.
export(float, 0, 30, .1) var damage: float = 2
export(Weapon.TYPES) var weapon: int = Weapon.TYPES.MEGA
export var n_collisions: int = 1 # Number of collisions before the bullet dissapears. Cero or negative for no max.
export var max_distance: float = 0 # Max distance travelled by this bullet before it dissapears. Cero or negative for no max.
var distance: float

var power: int
var dir: Vector2

onready var snd_bounce := $SndBounce


func _ready():
	dir = Vector2(cos(global_rotation), sin(global_rotation))
	if get_collision_layer_bit(1):
		add_to_group("player_bullets")


func _physics_process(delta):
	var velocity := motion_speed * dir
	var collision := move_and_collide(velocity * delta)
	
	collide(collision)
	
	distance += velocity.length()
	
	if max_distance > 0 and distance >= max_distance:
		disappear()


func _on_screen_exited():
	# Destroy itself if it has exited the screen.
	disappear()


func init(global_position, rotation, group):
	self.global_position = global_position
	self.rotation = rotation
	add_to_group(group)

#########################
## Auxiliar functions. ##
#########################


func collide(collision: KinematicCollision2D) -> void:
	if not is_instance_valid(collision):
		return
	
	var collider = collision.collider
	
	if collider is Shield:
		bounce(collision)
	elif collider is Character:
		hit_character(collider)


func hit_character(character) -> void:
	# self hits character. self collided with character.
	character.hit_bullet(self)
	n_collisions -= 1
	add_collision_exception_with(character)
	if n_collisions == 0:
		disappear()


func bounce(collision: KinematicCollision2D) -> void:
	snd_bounce.play()
	dir = -dir.reflect(collision.normal)
	global_rotation = dir.angle()
	add_collision_exception_with(collision.collider)


func disappear() -> void:
	queue_free()
