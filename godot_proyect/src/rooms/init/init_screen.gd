extends Control

const TITLE_SCREEN := "res://src/rooms/title screen/title_screen.tscn"

onready var godot_logo := $CenterContainer/GodotLogo
onready var disclaimer := $CenterContainer/Disclaimer

var can_skip: bool = OS.is_debug_build()

func _ready() -> void:
	get_tree().current_scene = self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and can_skip:
		load_title_screen()


func _on_GaspiLogoTween_tween_all_completed() -> void:
	# Animate GodotLogo.
	godot_logo.animate()


func _on_GodotLogoTween_tween_all_completed() -> void:
	# Animate Disclaimer.
	disclaimer.animate()
	# Allow to skip the disclaimer if the game has been started once before.
	can_skip = can_skip or Config.get_allow_intro_skip()
	

func _on_DisclaimerTween_tween_all_completed() -> void:
	# Load title screen.
	Config.set_allow_intro_skip(true)
	Config.save()
	yield(get_tree().create_timer(.3), "timeout")
	load_title_screen()


func load_title_screen() -> void:
	get_tree().change_scene(TITLE_SCREEN)
