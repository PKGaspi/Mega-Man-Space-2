extends Node

var starting = true

func _enter_tree() -> void:
	#get_tree().paused = true
	pass

func _process(delta : float) -> void:
	if starting:
		get_tree().paused = true
		if $GUILayer/CenterContainer.process_ready_text(delta):
			starting = false
			get_tree().paused = false
			$GameLayer/EnemyGenerator.new_random_horde()
	pass
