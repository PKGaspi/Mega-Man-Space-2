class_name ChargedWeaponState
extends WeaponState

export var stats: Resource


var charging_fases: int
var charging_time: float


func _ready() -> void:
	assert(stats != null)
	
	stats.initialize()
	charging_fases = stats.get_stat("charging_fases")
	charging_time = stats.get_stat("charging_time")

func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	# Set parent parameters.
	_parent.charging_fases = charging_fases
	_parent.charging_time = charging_time
	_parent.charging_timer.wait_time = charging_time
