extends MenuPanel
# Select Menu.


onready var star_frequency_slider := $"Contents/Sections/Additional/StarFrequencySlider"
onready var screen_shake_toggler := $"Contents/Sections/Additional/ScreenShakingToggler"
onready var flashing_toggler := $"Contents/Sections/Additional/FlashingToggler"



func _ready() -> void:
	Config.connect("setting_changed", self, "_on_config_setting_changed")
	
	# Set togglers, sliders and shifters state.
	
	screen_shake_toggler.set_checked(Config.get_screen_shake())
	flashing_toggler.set_checked(Config.get_flashing())
	
	star_frequency_slider.set_ratio(Config.get_star_frequency())


func _on_config_setting_changed(section: String, key: String, value) -> void:
	if section != "accesibility":
		return
	
	match key:
		#"star_frequency": star_frequency_shifter.entry_index = star_frequency_to_index(value)
		"screen_shake": screen_shake_toggler.set_checked(value)
		"flashing": flashing_toggler.set_checked(value)


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Star Frequency.
			# Do nothing. This setting is changed pressing left and right.
			pass
		1: # Screen Shaking.
			play_sound(snd_ui_up)
			Config.set_screen_shake(not screen_shake_toggler.get_checked())
		2: # Flashing.
			play_sound(snd_ui_up)
			Config.set_flashing(not flashing_toggler.get_checked())
		3: # Back.
			# Close this menu and save the config.
			play_sound(snd_ui_cancel)
			close_menu()


func _on_action_pressed_ui_cancel():
	play_sound(snd_ui_cancel)
	close_menu()


func _on_action_pressed_ui_left():
	match entry_index:
		0: # Star Frequency.
			var changed = star_frequency_slider.substract_step()
			if changed:
				play_sound(snd_ui_left)
				Config.set_star_frequency(star_frequency_slider.get_ratio())


func _on_action_pressed_ui_right():
	match entry_index:
		0: # Star Frequency.
			var changed = star_frequency_slider.add_step()
			if changed:
				play_sound(snd_ui_right)
				Config.set_star_frequency(star_frequency_slider.get_ratio())


func close_menu() -> void:
	# Save the config when exiting this menu.
	Config.save()
	.close_menu()
