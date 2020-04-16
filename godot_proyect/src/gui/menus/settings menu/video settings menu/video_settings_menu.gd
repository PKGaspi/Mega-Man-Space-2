extends MenuPanel
# Select Menu.

onready var window_scale_shifter := $"Contents/Sections/Additional/WindowScaleShifter"


func _ready() -> void:
	# Set window_scale values for this monitor.
	var max_scale: int = int(floor(OS.get_screen_size().y / get_viewport().get_visible_rect().size.y))
	print(max_scale)
	window_scale_shifter.entry_names.resize(max_scale)
	window_scale_shifter.entry_values.resize(max_scale)
	for i in range(max_scale):
		print(i)
		window_scale_shifter.entry_names[i] = "%dx" % (i + 1)
		window_scale_shifter.entry_values[i] = i + 1


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Fullscreen.
			Config.toggle_fullscreen()
		1: # Window Scale.
			pass
		2: # V-Sync.
			# Load the stage select scene.
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
	Config.save()
	.close_menu()
