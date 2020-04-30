extends Control

const TITLE_SCREEN := "res://src/rooms/title screen/title_screen.tscn"

onready var godot_logo := $CenterContainer/GodotLogo
onready var disclaimer := $CenterContainer/Disclaimer

var can_skip: bool = OS.is_debug_build()

func _ready() -> void:
	get_tree().current_scene = self


func _on_GaspiLogoTween_tween_all_completed() -> void:
	# Animate GodotLogo.
	godot_logo.animate()


func _on_GodotLogoTween_tween_all_completed() -> void:
	# Animate Disclaimer.
	disclaimer.animate()
	# Allow to skip the disclaimer if the game has been started once before.
	# can_skip = can_skip or Config.get_can_skip_intro()
	

func _on_DisclaimerTween_tween_all_completed() -> void:
	# Load title screen.
	yield(get_tree().create_timer(.3), "timeout")
	get_tree().change_scene(TITLE_SCREEN)
	# Config.set_can_skip_intro(true)
