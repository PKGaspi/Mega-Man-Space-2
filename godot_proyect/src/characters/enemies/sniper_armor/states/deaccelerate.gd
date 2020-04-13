extends EnemyState

var spr_ship: AnimatedSprite

func _ready() -> void:
	yield(owner,"ready")
	
	# Nodes.
	spr_ship = character.get_node("SprShip")



func enter(msg: Dictionary = {}) -> void:
	spr_ship.animation = "slide"
	spr_ship.play()


func physics_process(delta: float) -> void:
	# Move.
	_parent.velocity = _parent.calculate_velocity(Vector2.ZERO, delta)
	_parent.physics_process(delta)
	
	if megaship_in_view_distance() and _parent.velocity == Vector2.ZERO:
		_state_machine.transition_to("Move/Impulse")
