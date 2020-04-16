extends MenuPanel
# Select Menu.


func _ready() -> void:
	Config.connect("setting_changed", self, "_on_config_setting_changed")



func _on_config_setting_changed(section: String, key: String, value) -> void:
	if section != "control":
		return


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Back.
			# Close this menu and save the config.
			play_sound(snd_ui_cancel)
			close_menu()


func _on_action_pressed_ui_cancel():
	play_sound(snd_ui_cancel)
	close_menu()


func _on_action_pressed_ui_left():
	match entry_index:
		0:
			pass


func _on_action_pressed_ui_right():
	match entry_index:
		0:
			pass


func close_menu() -> void:
	# Save the config when exiting this menu.
	Config.save()
	.close_menu()
