
extends MenuPanel
# Select Menu.

var level_data: Resource
# Derivated menues.
const LEVEL := "res://src/rooms/level/level.tscn"
const SELECT_SCREEN := "res://src/rooms/select stage/select_stage.tscn"


func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Retry stage.
			assert(level_data != null)
			# Load level.
			var inst = load(LEVEL).instance()
			inst.level_data = level_data
			get_tree().current_scene.call_deferred("queue_free")
			get_tree().root.add_child(inst)
		1: # Select stage.
			get_tree().change_scene(SELECT_SCREEN)
		_: # Exit.
			global.exit_game()


func close_menu() -> void:
	pass
	# Override. This menu never closes.
