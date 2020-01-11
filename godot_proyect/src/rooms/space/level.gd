extends Node

const GAME_OVER_WAIT_TIME = 5 # In seconds.

var lvl_id = 0 # This is set when selecting the level.


func _ready() -> void:
	$Music.play()
	$GUILayer/CenterContainer/CenterText.set_animation("ready", 3, self, "_on_animation_finished")
	global.pause()
	
func _on_animation_finished(animation):
	if animation == "ready":
		$GameLayer/TeleportAnimation.pause_mode = PAUSE_MODE_PROCESS
		# Disable static camera.
		$GameLayer/StaticCamera.queue_free()
		$GameLayer/Megaship/Camera2D.current = true

func _on_teleport_animation_tree_exiting() -> void:
	global.unpause()
	$GameLayer/Megaship.visible = true
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

func death() -> void:
	$GUILayer/CenterContainer/CenterText.set_animation("none")
	$Music.stop()
	$GameOverTimer.start(GAME_OVER_WAIT_TIME)
	
	# TODO: Start timer for game over screen or something like that.

