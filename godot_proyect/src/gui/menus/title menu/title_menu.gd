
extends MenuPanel
# Select Menu.


# Derivated menues.
const SETTINGS_MENU := preload("res://src/gui/menus/settings menu/settings_menu.tscn")
const SELECT_SCREEN := "res://src/rooms/select stage/select_stage.tscn"


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Start.
			get_tree().change_scene(SELECT_SCREEN)
		1: # Settings.
			open_child_menu(SETTINGS_MENU)
		2: # Exit.
			global.exit_game()


func close_menu() -> void:
	pass
	# Override. This menu never closes.
