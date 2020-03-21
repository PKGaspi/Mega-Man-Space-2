extends CharacterState

export var teleport_speed: float = 260.0

var init_position: Vector2
var final_position: Vector2

var velocity: Vector2

var spr_ship

func _ready() -> void:
	yield(owner, "ready")
	spr_ship = character.spr_ship

func enter(msg: Dictionary = {}) -> void:
	# Set animation.
	spr_ship.set_animation("teleport_falling")
	spr_ship.play()
	
	# Setup values.
	var current_position = character.global_position
	if msg.has("init_position"):
		init_position = msg["init_position"]
		character.global_position = init_position
	else:
		init_position = current_position
	if msg.has("final_position"):
		final_position = msg["final_position"]
	else:
		final_position = current_position
	
	var dir = init_position.direction_to(final_position)
	velocity = dir * teleport_speed
	character.global_rotation = dir.angle() - PI / 2


func physics_process(delta: float) -> void:
	# Check if we have reached the final_position.
	# Check how far we are to final_position.
	var current_position = character.global_position
	var distance = current_position.distance_to(final_position)
	if distance < velocity.length() * delta:
		# This is the last movement.
		# TODO: play teleport end animation.
		_state_machine.transition_to("TeleportEnd")
	else:
		# Move towards the final_position.
		_parent.velocity = velocity
		_parent.physics_process(delta)

func exit() -> void:
	character.global_position = final_position
	_parent.velocity = Vector2.ZERO # Do not get propulsed at the end.
