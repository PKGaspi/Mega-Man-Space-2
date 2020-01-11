extends Node

const GAME_OVER_WAIT_TIME = 5 # In seconds.

var lvl_id = 0 # This is set when selecting the level.


func _ready() -> void:
	$Music.play()
	global.connect("user_pause", self, "_on_global_user_pause")
	$GUILayer/Container/CenterContainer/CenterText.set_animation("ready", 3, self, "_on_animation_finished")
	global.pause()
	
func _on_animation_finished(animation):
	if animation == "ready":
		$GameLayer/TeleportAnimation.pause_mode = PAUSE_MODE_PROCESS
		# Disable static camera.
		$GameLayer/StaticCamera.queue_free()
		$GameLayer/Megaship/Camera2D.current = true

func _on_teleport_animation_tree_exiting() -> void:
	global.unpause()
	#$GameLayer/Megaship.visible = true
	$GameLayer/EnemyGenerator.new_random_horde()

func _on_megaship_death() -> void:
	death()

func _on_boss_death() -> void:
	# TODO: Go to the select screen.
	pass
	
func _on_game_over_timer_timeout() -> void:
	global.lifes -= 1
	if global.lifes < 0:
		print(":(")
		global.game_over()
		# TODO: Go to game over screen and reset points.
	get_tree().reload_current_scene()

func _on_global_user_pause(value) -> void:
	$GUILayer/Container.visible = !value
	$GameLayer.visible = !value
	pause_mode = PAUSE_MODE_STOP if value else PAUSE_MODE_PROCESS
	if !value:
		global.MEGASHIP.visible = false
		var inst = preload("res://src/characters/megaship/megaship_teleport.tscn").instance()
		inst.global_position = global.MEGASHIP.global_position
		inst.destination = inst.global_position
		$GameLayer.add_child(inst)

func death() -> void:
	$GUILayer/CenterContainer/CenterText.set_animation("none")
	$Music.stop()
	$GameOverTimer.start(GAME_OVER_WAIT_TIME)
	
	# TODO: Start timer for game over screen or something like that.

