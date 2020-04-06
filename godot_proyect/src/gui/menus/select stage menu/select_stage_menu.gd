extends Control

export(Vector2) var selected: Vector2 = Vector2.ZERO
var entries = {}

signal actioned(entry_data)


func _ready() -> void:
	for child in get_children():
		if child is Control:
			entries[Vector2(child.column, child.row)] = child
	entries[selected].set_selected(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		emit_signal("actioned", entries[selected].entry_data)
	else:
		var new_selected = selected
		if event.is_action_pressed("ui_left"):
			new_selected = selected + Vector2.LEFT
		elif event.is_action_pressed("ui_right"):
			new_selected = selected + Vector2.RIGHT
		elif event.is_action_pressed("ui_up"):
			new_selected = selected + Vector2.UP
		elif event.is_action_pressed("ui_down"):
			new_selected = selected + Vector2.DOWN
		
		if set_selected(new_selected):
			$SndSelectionChange.play()


func set_selected(value : Vector2) -> bool:
	if value != selected and entries.has(value):
		entries[selected].set_selected(false)
		selected = value
		entries[selected].set_selected(true)
		return true
	else:
		return false
