extends EnemyState


var spr_body: AnimatedSprite
var shield: Shield # The shield node.
var shield_transform: Transform2D # Position and rotation for the shield in this state.

export var shield_time: float = 2.0
var shield_timer: Timer


func _ready() -> void:
	yield(owner,"ready")
	
	shield_transform = Transform2D(0, Vector2.ZERO)
	# Nodes.
	spr_body = character.get_node("SprBody")
	shield = character.get_node("Shield")
	
	shield_timer = Timer.new()
	shield_timer.name = "ShieldTimer"
	shield_timer.wait_time = shield_time
	add_child(shield_timer)


func _on_megaship_shooted() -> void:
	print("holi")
	shield_timer.start()


func _on_shield_timer_timeout() -> void:
	_state_machine.transition_to("Move/RandomDirection/Aim")


func enter(msg: Dictionary = {}) -> void:
	shield.transform = shield_transform
	spr_body.animation = "shield"
	spr_body.play()
	
	megaship.connect("shooted", self, "_on_megaship_shooted")
	shield_timer.connect("timeout", self, "_on_shield_timer_timeout")
	shield_timer.start()


func physics_process(delta: float) -> void:
	# Move.
	_parent.physics_process(delta)
	# Allways face the megaship.
	character.global_rotation = direction_to_megaship().rotated(-PI/2).angle()


func exit() -> void:
	megaship.disconnect("shooted", self, "_on_megaship_shooted")
	shield_timer.disconnect("timeout", self, "_on_shield_timer_timeout")
