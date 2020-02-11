extends Node

const GAME_OVER_WAIT_TIME = 5 # In seconds.

const MEGASHIP_TELEPORT = preload("res://src/characters/megaship/megaship_teleport.tscn")
const WEAPONS_MENU = preload("res://src/gui/menus/weapon menu/weapon_menu.tscn")

var lvl_id = 0 # This is set when selecting the level.

func _ready() -> void:
	$Music.play()
	global.connect("user_pause", self, "_on_global_user_pause")
	$GUILayer/Container/CenterContainer/CenterText.set_animation("ready", 3, self, "_on_animation_finished")
	global.pause()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("user_pause"):
		global.toggle_user_pause()


func _on_animation_finished(animation):
	if animation == "ready":
		global.create_touchscreen_layout($GUILayer/Container)
		$GameLayer/TeleportAnimation.pause_mode = PAUSE_MODE_PROCESS
		# Disable static camera.
		$GameLayer/StaticCamera.queue_free()
		$GameLayer/Megaship/Camera2D.current = true

func _on_teleport_animation_tree_exiting() -> void:
	global.unpause()
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
	if !value:
		global.MEGASHIP.visible = false
		var inst = MEGASHIP_TELEPORT.instance()
		var ship_pos = global.MEGASHIP.global_position
		inst.global_position = ship_pos
		inst.destination = ship_pos
		$GameLayer.add_child(inst)
	else:
		var inst = WEAPONS_MENU.instance()
		inst.set_palette(lvl_id)
		$GUILayer.add_child(inst)
		# Set active entry of the current weapon.
		var weapon_index = global.MEGASHIP.active_weapon
# warning-ignore:unused_variable
		for i in range(floor(weapon_index / 6)):
			inst.next_page()
		inst.set_entry((weapon_index % 6) + 1)

func death() -> void:
	$GUILayer/Container/CenterContainer/CenterText.set_animation("none")
	$Music.stop()
	$GameOverTimer.start(GAME_OVER_WAIT_TIME)
	
	# TODO: Start timer for game over screen or something like that.

