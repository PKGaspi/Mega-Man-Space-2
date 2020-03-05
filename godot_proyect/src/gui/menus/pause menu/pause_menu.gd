extends MenuPanel
# Pause Menu.

# Scenes.
const SELECT_SCREEN = "res://src/rooms/select stage/select_stage.tscn"
const TITLE_SCREEN = "res://src/rooms/title screen/title_screen.tscn"

func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Resume.
			# Unpause the game.
			global.set_user_pause(false)
		1: # Settings.
			# TODO: Open Settings menu.
			pass
		2: # Exit Stage.
			# Load the stage select scene.
			get_tree().change_scene(SELECT_SCREEN)
			global.set_user_pause(false)
		3: # Exit to Title Screen.
			get_tree().change_scene(TITLE_SCREEN)
			global.set_user_pause(false)
		4: # Exit to Desktop.
			# Close the game.
			global.exit_game()
