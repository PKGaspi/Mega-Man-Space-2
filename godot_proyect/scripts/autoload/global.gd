extends Node

onready var LIB = get_node("/root/library")

const EXITING_TIME = 1 # In seconds.
var exiting_timer = 0 # Time that the exit key has been pressed.

var MEGASHIP
func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		LIB.toggle_fullscreen()
	if Input.is_action_pressed("exit_game"):
		if exiting_timer >= EXITING_TIME:
			get_tree().quit()
		exiting_timer += delta
	else:
		exiting_timer = max(exiting_timer - delta, 0)