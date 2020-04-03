extends CharacterState

var spr_body: AnimatedPaletteSprite
var spr_propeller: AnimatedPaletteSprite

var _move_node_path: NodePath = "Move"
onready var _move_node := _state_machine.get_node(_move_node_path)
onready var max_speed: float

var tween: Tween


func _ready() -> void:
	yield(owner,"ready")
	
	# Nodes.
	spr_body = character.get_node("SprBody")
	spr_propeller = character.get_node("SprPropeller")
	
	# Stats.
	var stats = character.stats
	max_speed = stats.get_stat("max_speed")
	
	tween = Tween.new()
	tween.name = "Tween"
	add_child(tween)


func enter(msg: Dictionary = {}) -> void:
	# Setup animations.
	spr_body.play()
	spr_propeller.play()

	# Setup tween.
	_move_node.max_speed = 0
	tween.interpolate_property(_move_node, "max_speed", 0, max_speed, 3, Tween.TRANS_LINEAR, Tween.EASE_IN, .2)
	tween.start()
	tween.connect("tween_completed", self, "_on_tween_completed")


func physics_process(delta: float) -> void:
	# Move.
	_parent.physics_process(delta)
	spr_propeller.speed_scale = _move_node.velocity.length() / max_speed


func _on_tween_completed(object, key) -> void:
	if object == _move_node:
		tween.disconnect("tween_completed", self, "_on_tween_completed")
		_state_machine.transition_to("Move/Deaccelerate")
