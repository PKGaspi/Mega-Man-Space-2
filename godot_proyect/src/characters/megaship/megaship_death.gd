extends Node2D

func _ready() -> void:
	$RotatingParticles1.emitting = true
	$RotatingParticles2.emitting = true

func explode():
	$SndDeath.play()
	$SprShip.visible = false
	for node in get_children():
		if node is Particles2D:
			node.emitting = true
	
	$RotatingParticles1.emitting = false
	$RotatingParticles2.emitting = false

func _on_explosion_timer_timeout() -> void:
	explode()
