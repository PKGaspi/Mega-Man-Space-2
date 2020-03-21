extends CharacterState

var spr_ship

func _ready() -> void:
	yield(owner, "ready")
	spr_ship = character.spr_ship

func enter(msg: Dictionary = {}) -> void:
	spr_ship.set_animation("teleport_landing")
	spr_ship.play()
	spr_ship.connect("animation_finished", self, "_on_SprShip_animation_finished")

func _on_SprShip_animation_finished() -> void:
	spr_ship.disconnect("animation_finished", self, "_on_SprShip_animation_finished")
	spr_ship.set_animation("iddle")
	_state_machine.transition_to("Move/Travel")
