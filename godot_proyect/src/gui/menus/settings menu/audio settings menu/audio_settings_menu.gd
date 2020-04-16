extends MenuPanel
# Select Menu.


onready var master_slider := $"Contents/Sections/Additional/MasterSlider"
onready var sfx_slider := $"Contents/Sections/Additional/SfxSlider"
onready var music_slider := $"Contents/Sections/Additional/MusicSlider"
onready var mute_toggler := $"Contents/Sections/Additional/MuteToggler"



func _ready() -> void:
	Config.connect("setting_changed", self, "_on_config_setting_changed")
	
	# Set togglers, sliders and shifters state.
	
	master_slider.set_ratio(Config.get_bus_volume_ratio("Master"))
	sfx_slider.set_ratio(Config.get_bus_volume_ratio("Sfx"))
	music_slider.set_ratio(Config.get_bus_volume_ratio("Music"))
	mute_toggler.set_checked(Config.get_mute())
	


func _on_config_setting_changed(section: String, key: String, value) -> void:
	if section != "audio":
		return
	
	match key:
		"master_volume": master_slider.set_ratio(Config.get_bus_volume_ratio("Master"))
		"sfx_volume": sfx_slider.set_ratio(Config.get_bus_volume_ratio("Sfx"))
		"music_volume": music_slider.set_ratio(Config.get_bus_volume_ratio("Music"))
		"mute": mute_toggler.set_checked(Config.get_mute())


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Master Volume.
			# Do nothing. This setting is changed pressing left and right.
			pass
		1: # SFX Volume.
			# Do nothing. This setting is changed pressing left and right.
			pass
		2: # Music Volume.
			# Do nothing. This setting is changed pressing left and right.
			pass
		3: # V-Sync.
			Config.set_mute(not mute_toggler.get_checked())
		4: # Back.
			# Close this menu and save the config.
			close_menu()


func _on_action_pressed_ui_left():
	match entry_index:
		0: # Master Volume.
			master_slider.substract_step()
			Config.set_bus_volume_ratio("Master", master_slider.get_ratio())
		1: # SFX Volume.
			sfx_slider.substract_step()
			Config.set_bus_volume_ratio("Sfx", sfx_slider.get_ratio())
		2: # Music Volume.
			music_slider.substract_step()
			Config.set_bus_volume_ratio("Music", music_slider.get_ratio())


func _on_action_pressed_ui_right():
	match entry_index:
		0: # Master Volume.
			master_slider.add_step()
			Config.set_bus_volume_ratio("Master", master_slider.get_ratio())
		1: # SFX Volume.
			sfx_slider.add_step()
			Config.set_bus_volume_ratio("Sfx", sfx_slider.get_ratio())
		2: # Music Volume.
			music_slider.add_step()
			Config.set_bus_volume_ratio("Music", music_slider.get_ratio())


func close_menu() -> void:
	# Save the config when exiting this menu.
	Config.save()
	.close_menu()
