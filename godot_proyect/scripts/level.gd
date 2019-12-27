extends Node

func _enter_tree() -> void:
	$Music.play()
	global.pause = true
	$GUILayer/CenterContainer/CenterText.set_animation("ready", 3, self, "_on_animation_finished")

func _process(delta : float) -> void:
	# Set pause
	get_tree().paused = global.pause
	pass
	
func _on_animation_finished(animation):
	if animation == "ready":
		global.pause = false
		# Disable static camera.
		$GameLayer/Camera2D.current = false

func _on_teleport_animation_tree_exiting() -> void:
	$GameLayer/EnemyGenerator.new_random_horde()
