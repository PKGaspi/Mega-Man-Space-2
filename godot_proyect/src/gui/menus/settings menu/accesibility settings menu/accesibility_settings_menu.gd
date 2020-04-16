extends MenuPanel
# Select Menu.


onready var star_frequency_shifter := $"Contents/Sections/Additional/StarFrequencyShifter"
onready var screen_shake_toggler := $"Contents/Sections/Additional/ScreenShakingToggler"
onready var flashing_toggler := $"Contents/Sections/Additional/FlashingToggler"



func _ready() -> void:
	# Set togglers, sliders and shifters state.
	
	screen_shake_toggler.set_checked(Config.get_screen_shake())
	flashing_toggler.set_checked(Config.get_flashing())
	
	star_frequency_shifter.entry_index = star_frequency_to_index(Config.get_star_frequency())


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Star Frequency.
			# Do nothing. This setting is changed pressing left and right.
			pass
		1: # Screen Shaking.
			Config.toggle_screen_shake()
			screen_shake_toggler.set_checked(Config.get_screen_shake())
		2: # Flashing.
			Config.toggle_flashing()
			flashing_toggler.set_checked(Config.get_flashing())
		3: # Back.
			# Close this menu and save the config.
			close_menu()


func _on_action_pressed_ui_left():
	match entry_index:
		0: # Window Scale.
			star_frequency_shifter.previous_entry()
			Config.set_star_frequency(star_frequency_shifter.get_current_value())


func _on_action_pressed_ui_right():
	match entry_index:
		0: # Window Scale.
			star_frequency_shifter.next_entry()
			Config.set_star_frequency(star_frequency_shifter.get_current_value())


func close_menu() -> void:
	# Save the config when exiting this menu.
	Config.save()
	.close_menu()


func star_frequency_to_index(star_frequency: float) -> int:
	var index = max(0, star_frequency_shifter.entry_values.find(star_frequency))
	return index
