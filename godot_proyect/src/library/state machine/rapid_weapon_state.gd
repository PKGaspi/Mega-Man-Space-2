class_name RapidWeaponState
extends WeaponState

# Stats.
var max_bullets: int
var cooldown: float



func _ready() -> void:
	assert(weapon_stats != null)
	
	weapon_stats.initialize()
	max_bullets = weapon_stats.get_stat("max_bullets")
	cooldown = weapon_stats.get_stat("cooldown")


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	# Set parent parameters.
	_parent.max_bullets_base = max_bullets
	_parent.cooldown_base = cooldown
	_parent.cooldown_timer.wait_time = cooldown
