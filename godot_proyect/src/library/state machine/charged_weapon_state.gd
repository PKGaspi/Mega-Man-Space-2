class_name ChargedWeaponState
extends WeaponState

# Stats.
var charging_fases: int
var charging_time: float


func _ready() -> void:
	assert(weapon_stats != null)
	
	weapon_stats.initialize()
	charging_fases = weapon_stats.get_stat("charging_fases")
	charging_time = weapon_stats.get_stat("charging_time")


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	# Set parent parameters.
	_parent.charging_fases = charging_fases
	_parent.charging_time = charging_time
	_parent.charging_timer.wait_time = charging_time
