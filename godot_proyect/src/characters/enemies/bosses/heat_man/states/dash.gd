extends EnemyState


var path: Array
var path_index := 0


var spr_ship: AnimatedSprite
var ship_collision: CollisionShape2D
var dash_collision: CollisionShape2D
var shield: Shield
var snd_dash : AudioStreamPlayer2D

var dash_speed := 650.0


func _ready() -> void:
	yield(owner, "ready")
	shield = character.get_node("Shield")
	spr_ship = character.get_node("SprShip")
	snd_dash = character.get_node("SndDash")
	ship_collision = character.collision_box
	dash_collision = character.get_node("DashCollisionBox")


func _on_megaship_hitted(total_damage, direciton) -> void:
	dash_collision.disabled = true


func enter(msg: Dictionary = {}) -> void:
	snd_dash.play()
	character.set_collision_mask_bit(1, false)
	_parent.max_speed = dash_speed
	shield.visible = false
	ship_collision.disabled = true
	dash_collision.disabled = false
	path_index = 0
	
	# Set animation.
	spr_ship.set_animation("dashing")
	spr_ship.play()
	
	if is_instance_valid(megaship):
		megaship.connect("hitted", self, "_on_megaship_hitted")
	
	# Setup values.
	assert(msg.has("path"))
	path = msg["path"]


func physics_process(delta: float) -> void:
	var current_position = character.global_position
	# Move.
	var current_point: Vector2 = path[path_index]
	var dir = current_position.direction_to(current_point)
	var velocity = dir * dash_speed
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
	character.set_collision_mask_bit(1, true)
	_parent.max_speed = max_speed
	_parent.velocity = Vector2.ZERO
	shield.disable()
	ship_collision.disabled = false
	dash_collision.disabled = true
	
	if is_instance_valid(megaship):
		megaship.disconnect("hitted", self, "_on_megaship_hitted")
	
	# Set animation.
	spr_ship.set_animation("default")
	spr_ship.play()


func next_point() -> void:
	path_index += 1
	if path_index >= len(path):
		_state_machine.restart()
