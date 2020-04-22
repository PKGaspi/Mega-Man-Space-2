extends EnemyState


var shield: Shield
var preparing_timer: Timer = Timer.new()


func _ready() -> void:
	yield(owner, "ready")
	
	shield = character.get_node("Shield")
	
	preparing_timer.wait_time = 1.5
	preparing_timer.name = "PreparingTimer"
	add_child(preparing_timer)


func _on_preparing_timer_timeout() -> void:
	_state_machine.transition_to("RandomAttack")


func enter(msg: Dictionary = {}) -> void:
	shield.enable()
	preparing_timer.connect("timeout", self, "_on_preparing_timer_timeout")
	preparing_timer.start()


func exit() -> void:
	# Shield is not disabled. Shield must be disabled on depending on the attack.
	preparing_timer.disconnect("timeout", self, "_on_preparing_timer_timeout")
	preparing_timer.stop()
	
