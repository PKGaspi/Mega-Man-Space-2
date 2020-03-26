extends CharacterState

# Stats.
var stats

var max_speed: float
var acceleration_ratio: float

export var invert_movement := false
export var rotate_forwards := false
var velocity:= Vector2.ZERO

func _ready() -> void:
	yield(owner, "ready")
	stats = character.stats
	stats.connect("stat_changed", self, "_on_stat_changed")
	
	max_speed = stats.get_stat("max_speed")
	acceleration_ratio = stats.get_stat("acceleration_ratio")


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
	if rotate_forwards:
		character.global_rotation = velocity.rotated(PI/2).angle()



func get_collided_character() -> Character:
	# Check for collision.
	for i in range(character.get_slide_count()):
		var collider = character.get_slide_collision(i).collider
		if collider is Character:
			return collider
	return null


func calculate_velocity(
	move_direction: Vector2,
	acceleration: float,
	current_velocity: Vector2,
	delta: float
) -> Vector2:
	
	if invert_movement:
		move_direction = -move_direction
	
		
	var new_velocity: Vector2 
	if move_direction != Vector2.ZERO:
		# Accelerate.
		new_velocity = current_velocity + move_direction * acceleration * delta
	else:
		# Deaccelerate.
		var to_substract = current_velocity.normalized() * (acceleration * 4 / 5) * delta
		if current_velocity.length() < to_substract.length():
			# Stay in place if we are going the other way.
			new_velocity = Vector2.ZERO
		else:
			# Reduce velocity.
			new_velocity = current_velocity - to_substract
	
	
	current_velocity = new_velocity
	return new_velocity
