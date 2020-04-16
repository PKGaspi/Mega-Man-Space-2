tool
class_name Shifter
extends Label

const PREFIX := "< "
const SUFIX := " >"


export(Array, String) var entry_names: Array
export(Array) var entry_values: Array

export var entry_index: int = 0 setget set_entry

export var loop: bool = false


func _ready() -> void:
	pass


func set_entry(value: int) -> bool:
	var n_entries = len(entry_names)
	if not loop and (value < 0 or value >= n_entries):
		return false
		
	if loop:
		entry_index = fposmod(value, n_entries)
		text = PREFIX + str(entry_names[entry_index]) + SUFIX
	else:
		entry_index = clamp(value, 0, n_entries - 1)
		if entry_index == 0:
			text = str(entry_names[entry_index]) + SUFIX
		elif entry_index == n_entries - 1:
			text = PREFIX + str(entry_names[entry_index])
		else:
			text = PREFIX + str(entry_names[entry_index]) + SUFIX
	
	return true


func next_entry() -> bool:
	return set_entry(entry_index + 1)


func previous_entry() -> bool:
	return set_entry(entry_index - 1)


func get_current_name() -> String:
	return entry_names[entry_index]


func get_current_value():
	return entry_values[entry_index]
