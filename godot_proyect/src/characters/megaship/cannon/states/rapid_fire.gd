extends CannonState


var max_bullets: int
var cooldown: float
var cooldown_timer: Timer


func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)


func physics_process(delta: float) -> void:
	# This doesn't take cd into account. It assumes that cannons does for now.
	if Input.is_action_pressed("shoot"):
		
		# TODO: add max_projecitles limitation.
		if (cooldown_timer.is_stopped() and 
			max_bullets > len(get_tree().get_nodes_in_group("player_bullets"))
		):
			cooldown_timer.start()
			cannons.fire()
