tool
class_name OptionShifter
extends Label

const PREFIX := "< "
const SUFIX := " >"


export(Array, String) var entry_names: Array
export(Array) var entry_values: Array

export var entry_index: int = 0 setget set_entry

func _ready() -> void:
	pass


func set_entry(value: int) -> void:
	var n_entries = len(entry_names)
	if n_entries > 0:
		value = fposmod(value, n_entries)
		entry_index = value
		text = PREFIX + str(entry_names[entry_index]) + SUFIX


func next_entry() -> void:
	set_entry(entry_index + 1)


func previous_entry() -> void:
	set_entry(entry_index - 1)


func get_current_name() -> String:
	return entry_names[entry_index]


func get_current_value():
	return entry_values[entry_index]
