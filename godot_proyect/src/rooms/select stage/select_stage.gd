extends Control

func _on_entry_action_executed(column, row) -> void:
	queue_free()
