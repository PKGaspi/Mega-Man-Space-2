extends EnemyState


var hp_to_transition: float = 10
var received_damage: float
var shoot_timer: Timer = Timer.new()



func _ready() -> void:
	shoot_timer.wait_time = 2.2
	shoot_timer.name = "ShootTimer"
	add_child(shoot_timer)


func _on_character_hitted(total_damage: float, direction: Vector2) -> void:
	received_damage += total_damage
	
	if received_damage >= hp_to_transition:
		# Start a new attack.
		_state_machine.transition_to("PrepareAttack")


func _on_shoot_timer_timeout() -> void:
	shoot()


func shoot() -> void:
	character.shoot()
	shoot_timer.start()



func enter(msg: Dictionary = {}) -> void:
	received_damage = 0
	character.connect("hitted", self, "_on_character_hitted")
	shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
	
	shoot_timer.start()


func physics_process(delta: float) -> void:
	_parent.physics_process(delta)
	look_at_megaship()


func exit() -> void:
	shoot_timer.stop()
	character.disconnect("hitted", self, "_on_character_hitted")
	shoot_timer.disconnect("timeout", self, "_on_shoot_timer_timeout")
