extends EnemyState


var path: Array
var path_index := 0


var spr_ship
var ship_collision: CollisionShape2D
var dash_collision: CollisionShape2D


func _ready() -> void:
	yield(owner, "ready")
	spr_ship = character.get_node("SprShip")
	ship_collision = character.collision_box
	dash_collision = character.get_node("DashCollisionBox")


func enter(msg: Dictionary = {}) -> void:
	ship_collision.disabled = true
	dash_collision.disabled = false
	path_index = 0
	# Set animation.
	spr_ship.set_animation("dashing")
	spr_ship.play()
	
	# Setup values.
	assert(msg.has("path"))
	path = msg["path"]
	



func physics_process(delta: float) -> void:
	var current_position = character.global_position
	# Move.
	var current_point: Vector2 = path[path_index]
	var dir = current_position.direction_to(current_point)
	var velocity = dir * max_speed
	character.global_rotation = dir.rotated(PI/2).angle()
	
	# Check if we have reached the final_position.
	# Check how far we are to final_position.
	var distance = current_position.distance_to(current_point)
	if distance < velocity.length() * delta:
		# Target reached.
		character.global_position = current_point
		next_point()
	else:
		# Move towards the final_position.
		_parent.velocity = velocity
		_parent.physics_process(delta)


func exit() -> void:
	ship_collision.disabled = false
	dash_collision.disabled = true
	# Set animation.
	spr_ship.set_animation("default")
	spr_ship.play()


func next_point() -> void:
	path_index += 1
	if path_index >= len(path):
		_state_machine.transition_to("Iddle")
