class_name CharacterMoveState
extends CharacterState

# Stats.
var stats

var max_speed: float
var acceleration_ratio: float
var deacceleration_ratio: float

export var invert_movement := false
export var rotate_forwards := false
var velocity:= Vector2.ZERO

func _ready() -> void:
	yield(owner, "ready")
	stats = character.stats
	stats.connect("stat_changed", self, "_on_stat_changed")
	
	max_speed = stats.get_stat("max_speed")
	acceleration_ratio = stats.get_stat("acceleration_ratio")
	deacceleration_ratio = stats.get_stat("deacceleration_ratio")


func _on_stat_changed(stat_name: String, new_value: float) -> void:
	match stat_name:
		"max_speed": max_speed = stats.get_stat(stat_name)
		"acceleration_ratio": acceleration_ratio = stats.get_stat(stat_name)


func physics_process(delta):
	# Move.
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	character.move_and_slide(velocity)
	
	# Apply rotation.
	if rotate_forwards and velocity.length() > 0:
		character.global_rotation = velocity.rotated(PI/2).angle()



func get_collided_character() -> Character:
	# Check for collision.
	for i in range(character.get_slide_count()):
		var collider = character.get_slide_collision(i).collider
		if collider is Character:
			return collider
	return null


func calculate_velocity(
	propulsion: Vector2,
	delta: float
) -> Vector2:
	
	var current_velocity = velocity
	var acceleration = acceleration_ratio * max_speed
	var deacceleration = deacceleration_ratio * max_speed
	
	if invert_movement:
		propulsion = -propulsion
	
		
	var new_velocity: Vector2 
	if propulsion != Vector2.ZERO:
		# Accelerate.
		new_velocity = current_velocity + propulsion * acceleration * delta
	else:
		# Deaccelerate.
		var to_substract = current_velocity.normalized() * deacceleration * delta
		if current_velocity.length() < to_substract.length():
			# Stay in place if we are going the other way.
			new_velocity = Vector2.ZERO
		else:
			# Reduce velocity.
			new_velocity = current_velocity - to_substract
	
	
	return new_velocity
