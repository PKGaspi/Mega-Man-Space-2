extends EnemyState


var angular_speed: float = 0
var max_angular_speed: float = PI
var angular_acceleration: float = PI/2

var attack_timer: Timer = Timer.new()
var shoot_timer: Timer = Timer.new()

var way: int = 1

var shield: Shield

var rng := global.init_random()



func _ready() -> void:
	yield(owner, "ready")
	
	shield = character.get_node("Shield")
	
	# Setup timers.
	attack_timer.wait_time = 4
	attack_timer.name = "AttackTimer"
	add_child(attack_timer)
	shoot_timer.wait_time = .1
	shoot_timer.name = "ShootTimer"
	add_child(shoot_timer)


func _on_attack_timer_timeout() -> void:
	_state_machine.restart()


func _on_shoot_timer_timeout() -> void:
	character.shoot()


func enter(msg: Dictionary = {}) -> void:
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	attack_timer.start()
	shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
	shoot_timer.start()
	
	angular_speed = 0
	
	way = int(sign(rng.randf_range(-1, 1)))


func physics_process(delta: float) -> void:
	angular_speed = min(angular_speed + angular_acceleration * delta, max_angular_speed)
	character.rotation += angular_speed * delta * way


func exit() -> void:
	attack_timer.disconnect("timeout", self, "_on_attack_timer_timeout")
	attack_timer.stop()
	shoot_timer.disconnect("timeout", self, "_on_shoot_timer_timeout")
	shoot_timer.stop()
	
	angular_speed = 0
	shield.disable()
