extends CannonState


var max_bullets_base: int
var cooldown_base: float
var cooldown_timer: Timer


func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)


func physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		
		# Check cooldown.
		if cooldown_timer.is_stopped():
			# Check max_bullets.
			var max_bullets = max_bullets_base + cannons.max_bullets_extra
			if max_bullets > len(get_tree().get_nodes_in_group("player_bullets")):
				# Fire, everything is correct.
				var cooldown = cooldown_base - cannons.max_bullets_extra * .2
				cooldown_timer.start(cooldown)
				cannons.fire()
