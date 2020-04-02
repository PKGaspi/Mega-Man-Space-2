extends CharacterState


var spr_body: AnimatedPaletteSprite
var spr_propeller: AnimatedPaletteSprite


var _move_node_path: NodePath = "Move"
onready var _move_node := _state_machine.get_node(_move_node_path)
onready var max_speed: float

func _ready() -> void:
	yield(owner,"ready")
	
	# Nodes.
	spr_body = character.get_node("SprBody")
	spr_propeller = character.get_node("SprPropeller")
	
	# Stats.
	var stats = character.stats
	max_speed = stats.get_stat("max_speed")


func enter(msg: Dictionary = {}) -> void:
	spr_body.stop()


func physics_process(delta: float) -> void:
	# Move.
	_parent.velocity = _parent.calculate_velocity(Vector2.ZERO, delta)
	_parent.physics_process(delta)
	
	spr_propeller.speed_scale = _move_node.velocity.length() / max_speed
	
	if _parent.velocity.length() == 0:
		_state_machine.transition_to("Move/Follow/Megaship/Accelerate")
