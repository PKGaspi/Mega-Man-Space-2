extends CharacterState

# Speed and acceleration.

const MIN_MAX_SPEED:= 200.0
export var max_speed:= 260.0 setget set_max_speed
const MAX_MAX_SPEED:= 400.0
export var acceleration_ratio:= 7/4

var velocity:= Vector2.ZERO



func physics_process(delta):
	# Move.
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	character.move_and_slide(velocity)
	


## Setters and getters. ##

func set_max_speed(value: float) -> void:
	max_speed = clamp(value, MIN_MAX_SPEED, MAX_MAX_SPEED)
	print(max_speed)


func get_collided_character() -> Character:
	# Check for collision.
	for i in range(character.get_slide_count()):
		var collider = character.get_slide_collision(i).collider
		if collider is Character:
			return collider
	return null
