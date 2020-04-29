extends Control

const TITLE_SCREEN := "res://src/rooms/title screen/title_screen.tscn"

onready var disclaimer := $Disclaimer

func _ready() -> void:
	get_tree().current_scene = self


func _on_LogoTween_tween_all_completed() -> void:
	# Animate disclaimer.
	disclaimer.animate()


func _on_DisclaimerTween_tween_all_completed() -> void:
	# Load title screen.
	yield(get_tree().create_timer(.3), "timeout")
	get_tree().change_scene(TITLE_SCREEN)
