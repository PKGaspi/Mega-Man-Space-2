extends EnemyState


var spr_ship: AnimatedSprite
var charged := false


func _ready() -> void:
	yield(owner,"ready")
	
	# Nodes.
	spr_ship = character.get_node("SprShip")
	spr_ship.connect("animation_finished", self, "_on_spr_ship_animation_finished")


func _on_spr_ship_animation_finished() -> void:
	charged = true

func enter(msg: Dictionary = {}) -> void:
	charged = false
	spr_ship.animation = "contract"
	spr_ship.play()


func physics_process(delta: float) -> void:
	print(_parent.velocity)
	var dir = direction_to_megaship()
	
	character.global_rotation = dir.rotated(PI/2).angle()
	
	if megaship_in_view_distance() and charged:
		# Move
		_parent.velocity = dir * _parent.max_speed
		_parent.physics_process(delta)
		
		# Start deaccelerating.
		_state_machine.transition_to("Move/Deaccelerate")
