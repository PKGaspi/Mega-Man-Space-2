extends CharacterState

# Stats.
var stats

var max_speed: float
var acceleration_ratio: float

var velocity:= Vector2.ZERO

func _ready() -> void:
	yield(owner, "ready")
	stats = character.stats
	stats.connect("stat_changed", self, "_on_stats_stat_changed")
	
	max_speed = stats.get_stat("max_speed")
	acceleration_ratio = stats.get_stat("acceleration_ratio")


func _on_stats_stat_changed(stat_name: String, new_value: float) -> void:
	match stat_name:
		"max_speed": max_speed = stats.get_stat(stat_name)
		"acceleration_ratio": acceleration_ratio = stats.get_stat(stat_name)
		


func physics_process(delta):
	# Move.
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	character.move_and_slide(velocity)


func get_collided_character() -> Character:
	# Check for collision.
	for i in range(character.get_slide_count()):
		var collider = character.get_slide_collision(i).collider
		if collider is Character:
			return collider
	return null
