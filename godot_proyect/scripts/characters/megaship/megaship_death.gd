extends Node2D

func explode():
	$SndDeath.play()
	$SprShip.visible = false
	for node in get_children():
		print(node.name)
		if node is Particles2D:
			node.emitting = true

func _on_explosion_timer_timeout() -> void:
	explode()
