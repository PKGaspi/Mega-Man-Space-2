extends MenuPanel
# Select Menu.

func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Fullscreen.
			# TODO: Overwrite setting in config.
			global.toggle_fullscreen()
		1: # Window Scale.
			pass
		2: # V-Sync.
			# Load the stage select scene.
			pass
		3: # Back.
			# Close this menu and save the config.
			close_menu()
