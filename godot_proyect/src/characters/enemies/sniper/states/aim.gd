extends EnemyState


var spr_body: AnimatedSprite
var shield: Shield # The shield node.
var shield_transform: Transform2D # Position and rotation for the shield in this state.

export var n_total_shoots: int = 3
var n_shoots: int
export var shoot_cd: float = .5
var shoot_timer: Timer


func _ready() -> void:
	yield(owner,"ready")
	
	shield_transform = Transform2D(PI / 2, Vector2(3, 0))
	# Nodes.
	spr_body = character.get_node("SprBody")
	shield = character.get_node("Shield")
	
	shoot_timer = Timer.new()
	shoot_timer.name = "ShootTimer"
	shoot_timer.wait_time = shoot_cd
	add_child(shoot_timer)


func _on_shoot_timer_timeout() -> void:
	if n_shoots == 0:
		_state_machine.transition_to("Move/RandomDirection/Shield")
	else:
		shoot()


func enter(msg: Dictionary = {}) -> void:
	shield.transform = shield_transform
	spr_body.animation = "aim"
	spr_body.play()
	
	n_shoots = n_total_shoots
	
	shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
	shoot_timer.start()


func physics_process(delta: float) -> void:
	# Move.
	_parent.physics_process(delta)
	# Allways face the megaship.
	rotate_towards_megaship()


func exit() -> void:
	shoot_timer.disconnect("timeout", self, "_on_shoot_timer_timeout")


func shoot() -> void:
	if megaship_in_view_distance():
		character.shoot()
	n_shoots -= 1
