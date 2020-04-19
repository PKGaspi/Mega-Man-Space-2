extends CharacterState

const MIN_DISTANCE_TO_CURSOR = 5 # In pixels.

var spr_ship

func _ready() -> void:
	yield(owner, "ready")
	spr_ship = character.spr_ship

func enter(msg: Dictionary = {}) -> void:
	spr_ship.set_animation("teleport_landing")
	spr_ship.play()
	spr_ship.connect("animation_finished", self, "_on_SprShip_animation_finished")


func physics_process(delta: float) -> void:
	character.global_rotation = calculate_rotation()


func _on_SprShip_animation_finished() -> void:
	# Transition to travel and reset velocity.
	_state_machine.transition_to("Move/Travel", {"velocity": Vector2.ZERO})


func exit() -> void:
	character.snd_teleport.play()
	spr_ship.disconnect("animation_finished", self, "_on_SprShip_animation_finished")
	spr_ship.set_animation("iddle")


func calculate_rotation() -> float:
	var rotation:= character.rotation
	
	match global.input_type:
		global.INPUT_TYPES.KEY_MOUSE: # Keyboard and mouse input.
			var mouse_pos = character.get_global_mouse_position()
			var global_position = character.global_position
			if global_position.distance_to(mouse_pos) > MIN_DISTANCE_TO_CURSOR:
				rotation = global_position.direction_to(mouse_pos).rotated(PI/2).angle()
		_:
			pass #rotation = 
	return rotation
