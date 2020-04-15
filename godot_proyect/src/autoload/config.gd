extends Node

const CONFIG_PATH := "user://settings.cfg"
const DEFAULT_CONFIG_PATH := "res://resources/default_settings.cfg"
var config := ConfigFile.new()


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


func save() -> void:
	config.save(CONFIG_PATH)


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
			if not config.has_section_key(section, key):
				config.set_value(section, key, default_config.get_value(section, key))
	

