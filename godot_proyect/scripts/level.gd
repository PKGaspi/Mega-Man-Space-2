extends Node

func _enter_tree() -> void:
	global.pause = true
	$GUILayer/CenterContainer.set_animation("ready", 2.5, self, "_on_animation_finished")
	pass

func _process(delta : float) -> void:
	# Set pause
	get_tree().paused = global.pause
	pass
	
func _on_animation_finished(animation):
	if animation == "ready":
		$GameLayer/EnemyGenerator.new_random_horde()
		global.pause = false