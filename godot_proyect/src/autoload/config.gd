extends Node

const CONFIG_PATH := "user://settings.cfg"
const DEFAULT_CONFIG_PATH := "res://resources/default_settings.cfg"
var config := ConfigFile.new()

signal setting_changed(section, key, value)


func _init() -> void:
	# Check if the config file exists.
	var cfg_file = File.new()
	if not cfg_file.file_exists(CONFIG_PATH):
		# Create config file.
		var err = cfg_file.open(CONFIG_PATH, File.WRITE_READ)
		if err != OK:
			printerr("Error: Couldn't create config file. ", err)
			return
	
	# Load the config file.
	var err = config.load("user://settings.cfg")
	if err != OK:
		printerr("Error: Couldn't load config file. ", err)
		return
	
	# Ensure that all fields are in the file.
	ensure_config()
	
	#set_window_scale(4)
	#call_deferred("set_bus_volume_scale", "Master", 0)


func save() -> void:
	config.save(CONFIG_PATH)


func set_value(section: String, key: String, value) -> void:
	config.set_value(section, key, value)
	emit_signal("setting_changed", section, key, value)


func get_value(section: String, key: String, default_value = null):
	return config.get_value(section, key, default_value)


func ensure_config() -> void:
	# Ensures that every field in the default config is in
	# the current config. If the field already exists, it
	# remains unchanged. If it doesn't, it will be written with
	# the default value.
	
	var default_config := ConfigFile.new()
	var err = default_config.load(DEFAULT_CONFIG_PATH)
	
	if err != OK:
		printerr("Error: Missing default config", err)
		return
	
	for section in default_config.get_sections():
		for key in default_config.get_section_keys(section):
			var default_value = default_config.get_value(section, key)
			var value = config.get_value(section, key, default_value)
			call_setting_method(section, key, value)
	
	save()

func call_setting_method(section: String, key: String, value) -> void:
	# Calls the method that applies certain setting. The setting is 
	# defined as in the .ini file. This method does not update the
	# .ini file. The called method shouls be doing that.
	match section:
		"video":
			match key:
				"fullscreen": set_fullscreen(value)
				_: set_value(section, key, value)
		_: set_value(section, key, value)


## Settings functions. ##


## Accesibility. ##

func set_star_frequency(value: int) -> void:
	set_value("accesibility", "star_frequency", value)

func get_star_frequency() -> int:
	return get_value("accesibility", "star_frequency")


func set_screen_shake(value: bool) -> void:
	set_value("accesibility", "screen_shake", value)
	# TODO: Implement (or not, maybe the signal emitted is enough).

func get_screen_shake() -> bool:
	return get_value("accesibility", "screen_shake")

func toggle_screen_shake() -> void:
	set_screen_shake(not get_screen_shake())


func set_flashing(value: bool) -> void:
	set_value("accesibility", "flashing", value)
	# TODO: Implement (or not, maybe the signal emitted is enough).

func get_flashing() -> bool:
	return get_value("accesibility", "flashing")

func toggle_flashing() -> void:
	set_flashing(not get_flashing())




## Video. ##

func set_fullscreen(value: bool) -> void:
	OS.window_fullscreen = value
	global.fix_mouse_mode()
	set_value("video", "fullscreen", value)
	if !value:
		set_window_scale(get_window_scale())

func get_fullscreen() -> bool:
	return get_value("video", "fullscreen")
	
func toggle_fullscreen() -> void:
	set_fullscreen(not get_fullscreen())


func set_vsync(value: bool) -> void:
	OS.vsync_enabled = value
	set_value("video", "v-sync", value)

func get_vsync() -> bool:
	return get_value("video", "v-sync")

func toggle_vsync() -> void:
	set_vsync(not get_vsync())


func set_window_scale(value: int) -> void:
	
	var viewport := get_viewport()
	if not is_instance_valid(viewport):
		# If there is no viewport, try again next time.
		call_deferred("set_window_scale", value)
		return
	
	set_value("video", "window_scale", value)
	if get_fullscreen():
		# Do nothing if the game is fullscreen.
		return
	
	OS.window_size = viewport.get_visible_rect().size * value
	OS.center_window()
	# TODO: Fix window not centering if the game was started fullscreen
	# or the window_scale changed while fullscreen. Making the function
	# to be called deferred fixes nothing.

func get_window_scale() -> int:
	return get_value("video", "window_scale")


func set_aspect_ratio(value: float) -> void:
	
	var viewport := get_viewport()
	var tree := get_tree()
	if not is_instance_valid(viewport) or not is_instance_valid(tree):
		# If there is no viewport, try again next time.
		call_deferred("set_aspect_ratio", value)
		return
	
	var height = viewport.get_visible_rect().size.y
	var new_size = Vector2(height * value, height)
	
	# TODO: Change the viewport's size.
	# TODO: Set aspect ratio to ignore.
	# tree.set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_IGNORE, ?????)
	OS.window_size = new_size
	# tree.set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, ???????)
	# TODO: Set aspect ratio to keep.


## Audio. ##

func set_bus_volume_scale(bus_name: String, volume_scale: float) -> void:
	volume_scale = clamp(volume_scale, 0.0, 1.0)
	set_value("audio", bus_name.to_lower() + "_volume", volume_scale)
	
	var volume_db: float = lerp(-40.0, 6.0, volume_scale)
	print(volume_db)
	set_bus_mute(bus_name, volume_db <= -40.0 or (get_mute() and bus_name == "master"))
	print(AudioServer.get_bus_index(bus_name))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), volume_db)

func get_bus_volume_scale(bus_name: String) -> float:
	return get_value("audio", bus_name.to_lower() + "_volume")


func set_bus_mute(bus_name: String, value: bool) -> void:
	print(value)
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus_name), value)

func set_mute(value: bool) -> void:
	set_value("audio", "mute", value)
	set_bus_mute("Master", value)

func get_mute() -> bool:
	return get_value("audio", "mute")


## Controls. ##
