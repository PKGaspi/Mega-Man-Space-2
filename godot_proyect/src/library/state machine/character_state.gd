class_name CharacterState
extends State

var character: Character

# Stats.
var stats

var max_speed: float
var acceleration_ratio: float
var deacceleration_ratio: float
var view_distance: float


func _ready() -> void:
	yield(owner, "ready")
	character = owner
	
	stats = character.stats
	
	max_speed = stats.get_stat("max_speed")
	acceleration_ratio = stats.get_stat("acceleration_ratio")
	deacceleration_ratio = stats.get_stat("deacceleration_ratio")
	view_distance = stats.get_stat("view_distance")
