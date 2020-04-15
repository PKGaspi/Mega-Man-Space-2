extends MenuPanel
# Select Menu.


# Derivated menues.
const ACCESIBILITY_MENU = preload("res://src/gui/menus/yesno menu/yesno_menu.tscn")

func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Accesibility settings.
			pass
		1: # Video settings.
			pass
		2: # Audio settings.
			# Load the stage select scene.
			pass
		3: # Controls settings.
			pass
		4: # Other settings.
			pass
		5: # Back.
			# Close this menu.
			close_menu()
