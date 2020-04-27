extends Control

const TITLE_SCREEN := "res://src/rooms/title screen/title_screen.tscn"

func _ready() -> void:
	get_tree().current_scene = self


func _on_Tween_tween_all_completed() -> void:
	# Load title screen.
	yield(get_tree().create_timer(.5), "timeout")
	get_tree().change_scene(TITLE_SCREEN)
