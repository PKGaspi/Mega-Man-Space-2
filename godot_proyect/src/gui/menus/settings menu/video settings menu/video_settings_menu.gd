extends MenuPanel
# Select Menu.


onready var fullscreen_toggler := $"Contents/Sections/Additional/FullscreenToggler"
onready var window_scale_shifter := $"Contents/Sections/Additional/WindowScaleShifter"
onready var vsync_toggler := $"Contents/Sections/Additional/VSyncToggler"



func _ready() -> void:
	Config.connect("setting_changed", self, "_on_config_setting_changed")
	
	# Set togglers, sliders and shifters state.
	
	fullscreen_toggler.set_checked(Config.get_fullscreen())
	vsync_toggler.set_checked(Config.get_vsync())
	
	
	# Set window_scale values for this monitor.
	var max_scale: int = int(floor(OS.get_screen_size().y / get_viewport().get_visible_rect().size.y))
	window_scale_shifter.entry_names.resize(max_scale)
	window_scale_shifter.entry_values.resize(max_scale)
	for i in range(max_scale):
		window_scale_shifter.entry_names[i] = "%dx" % (i + 1)
		window_scale_shifter.entry_values[i] = i + 1
	
	window_scale_shifter.set_entry(Config.get_window_scale() - 1)


func _on_config_setting_changed(section: String, key: String, value) -> void:
	if section != "video":
		return
	
	match key:
		"fullscreen": fullscreen_toggler.set_checked(value)
		"v-sync": vsync_toggler.set_checked(value)
		"window_scale": window_scale_shifter.set_entry(value - 1)


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Fullscreen.
			play_sound(snd_ui_up)
			Config.toggle_fullscreen()
		1: # Window Scale.
			# Do nothing. This setting is changed pressing left and right.
			pass
		2: # V-Sync.
			play_sound(snd_ui_up)
			Config.toggle_vsync()
		3: # Back.
			# Close this menu and save the config.
			play_sound(snd_ui_cancel)
			close_menu()


func _on_action_pressed_ui_cancel():
	play_sound(snd_ui_cancel)
	close_menu()


func _on_action_pressed_ui_left():
	match entry_index:
		1: # Window Scale.
			var changed = window_scale_shifter.previous_entry()
			if changed:
				play_sound(snd_ui_left)
				Config.set_window_scale(window_scale_shifter.get_current_value())


func _on_action_pressed_ui_right():
	match entry_index:
		1: # Window Scale.
			var changed = window_scale_shifter.next_entry()
			if changed:
				play_sound(snd_ui_right)
				Config.set_window_scale(window_scale_shifter.get_current_value())


func close_menu() -> void:
	# Save the config when exiting this menu.
	Config.save()
	.close_menu()
