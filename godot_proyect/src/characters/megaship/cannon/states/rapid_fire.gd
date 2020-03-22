extends WeaponState


func physics_process(delta: float) -> void:
	# This doesn't take cd into account. It assumes that cannons does for now.
	if Input.is_action_pressed("shoot"):
		cannons.fire()
