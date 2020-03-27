class_name RapidWeaponState
extends WeaponState

# Stats.
var max_bullets: int
var cooldown: float



func _ready() -> void:
	assert(stats != null)
	
	stats.initialize()
	max_bullets = stats.get_stat("max_bullets")
	cooldown = stats.get_stat("cooldown")


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	# Set parent parameters.
	_parent.max_bullets = max_bullets
	_parent.cooldown = cooldown
	_parent.cooldown_timer.wait_time = cooldown
