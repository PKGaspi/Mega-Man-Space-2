extends MenuPanel
# Select Menu.


# Derivated menues.
const ACCESIBILITY_MENU = preload("res://src/gui/menus/settings menu/video settings menu/video_settings_menu.tscn")
const VIDEO_MENU = preload("res://src/gui/menus/settings menu/video settings menu/video_settings_menu.tscn")
const AUDIO_MENU = preload("res://src/gui/menus/settings menu/video settings menu/video_settings_menu.tscn")
const CONTROLS_MENU = preload("res://src/gui/menus/settings menu/video settings menu/video_settings_menu.tscn")
const OTHER_MENU = preload("res://src/gui/menus/settings menu/video settings menu/video_settings_menu.tscn")

func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Accesibility settings.
			open_child_menu(ACCESIBILITY_MENU)
		1: # Video settings.
			open_child_menu(VIDEO_MENU)
		2: # Audio settings.
			open_child_menu(AUDIO_MENU)
		3: # Controls settings.
			open_child_menu(CONTROLS_MENU)
		4: # Other settings.
			open_child_menu(OTHER_MENU)
		5: # Back.
			# Close this menu.
			close_menu()
