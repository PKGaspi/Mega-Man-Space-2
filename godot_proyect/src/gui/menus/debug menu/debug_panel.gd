extends Control

#const kdfj = preload("res://src/bullets/bullet.tscn")

var active = false setget set_active
onready var menu = get_node("MarginContainer/Entries/Options")

func _ready() -> void:
	set_active(active)
	if !OS.is_debug_build():
		queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_menu"):
		toggle_active()

func set_active(value: bool) -> void:
	active = value
	visible = value
	menu.set_active(value and !global.is_paused)
	if value:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func toggle_active() -> void:
	set_active(!active)
