extends CharacterState

export var knockback_time: float # In s.
export var knockback_multiplier: float # In (pixels/s)/damage_point. 
var knockback_speed: float # In pixels/s. 

var knockback_dir: Vector2
var _timer := Timer.new()



func _ready() -> void:
	_timer.one_shot = true
	_timer.connect("timeout", self, "_on_knockback_timeout")
	add_child(_timer)


func physics_process(delta: float) -> void:
	_parent.velocity = knockback_dir.normalized() * knockback_speed
	_parent.physics_process(delta)


func enter(msg: Dictionary = {}) -> void:
	assert(msg.has("dir") and msg.has("damage"))
	knockback_dir = msg["dir"]
	knockback_speed = knockback_multiplier * msg["damage"]
	
	# Set timer.
	_timer.start(knockback_time)


func _on_knockback_timeout() -> void:
	_state_machine.transition_to("Move/Travel")
