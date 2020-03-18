class_name Stats
extends Resource

# List with all the stat names.
var _stats := []
# Dictionaries to store initial, current, min and max values for all stats.
var _stat_initial := {}
var _stat_current := {}
var _stat_caps := {}

signal stat_changed(stat_name, new_value)


func _init() -> void:
	_init_lists()


func get_stat(stat_name: String) -> float:
	assert(stat_name in _stats)
	return _stat_current[stat_name]


func modify_stat(stat_name: String, ammount: float) -> void:
	assert(stat_name in _stats)
	var old_value = get_stat(stat_name)
	var cap = _stat_caps[stat_name]
	var new_value = clamp(old_value + ammount, cap.x, cap.y)
	if old_value != new_value:
		_stat_current[stat_name] = new_value
		emit_signal("stat_changed", stat_name, new_value)


func reset_stat(stat_name: String) -> void:
	assert(stat_name in _stats)
	_stat_current[stat_name] = _stat_initial[stat_name]


func reset_all_stats() -> void:
	for stat in _stats:
		reset_stat(stat)


func _init_lists() -> void:
	var ignore:= [
		"resource_local_to_scene",
		"resource_name",
		"resource_path",
		"script",
		"_stats",
		"_modifiers",
		"_cache"
	] # Values to ignore.
	_stats = []
	_stat_initial = {}
	_stat_current = {}
	_stat_caps = {}
	for property in get_property_list():
		if property.name[0].capitalize() == property.name[0]:
			continue # Ignore.
		if property.name in ignore:
			continue # Ignore.
		if property.name.substr(0, 4) == "_cap":
			_stat_caps[property.name] = get(property.name)
			continue # Ignore. 
		_stats.append(property.name)
		_stat_initial[property.name] = get(property.name)
		_stat_current[property.name] = get(property.name)
