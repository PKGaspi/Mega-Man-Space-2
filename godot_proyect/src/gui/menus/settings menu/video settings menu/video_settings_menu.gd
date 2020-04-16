extends MenuPanel
# Select Menu.


onready var fullscreen_toggler := $"Contents/Sections/Additional/FullscreenToggler"
onready var window_scale_shifter := $"Contents/Sections/Additional/WindowScaleShifter"
onready var vsync_toggler := $"Contents/Sections/Additional/VSyncToggler"



func _ready() -> void:
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


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Fullscreen.
			fullscreen_toggler.toggle_checked()
			Config.toggle_fullscreen()
		1: # Window Scale.
			# Do nothing. This setting is changed pressing left and right.
			pass
		2: # V-Sync.
			vsync_toggler.toggle_checked()
			Config.toggle_vsync()
			pass
		3: # Back.
			# Close this menu and save the config.
			close_menu()


func _on_action_pressed_ui_left():
	match entry_index:
		1: # Window Scale.
			window_scale_shifter.previous_entry()
			Config.set_window_scale(window_scale_shifter.get_current_value())


func _on_action_pressed_ui_right():
	match entry_index:
		1: # Window Scale.
			window_scale_shifter.next_entry()
			Config.set_window_scale(window_scale_shifter.get_current_value())


func close_menu() -> void:
	# Save the config when exiting this menu.
	Config.save()
	.close_menu()
