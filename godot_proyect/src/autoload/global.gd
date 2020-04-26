extends Node

const CURSOR := preload("res://assets/sprites/gui/cursor.png")
const TOUCHSCREEN_LAYOUT := preload("res://src/gui/touchscreen_layout.tscn")

const BASE_RES := Vector2(480, 270)

onready var snd_collect := $SndCollect
onready var game_exit_timer := $GameExitTimer

export var stats: Resource

var is_paused := false
var user_pause := false
var os := OS.get_name()

var current_touchscreen_layout = null

enum INPUT_TYPES {
	KEY_MOUSE,
	GAMEPAD,
	TOUCHSCREEN,
}

var input_type : int # Wheter the game is being played with a gamepad or a keyboard.

# Weapons.
var unlocked_weapons = {
	Weapon.TYPES.MEGA : true,
	Weapon.TYPES.BUBBLE : false,
	Weapon.TYPES.AIR : false,
	Weapon.TYPES.QUICK : false,
	Weapon.TYPES.HEAT : false,
	Weapon.TYPES.WOOD : false,
	Weapon.TYPES.METAL : false,
	Weapon.TYPES.FLASH : false,
	Weapon.TYPES.CRASH : false,
	Weapon.TYPES.ONE : false,
	Weapon.TYPES.TWO : false,
	Weapon.TYPES.THREE : false,
}

var one_ups: int
var e_tanks: int

var MEGASHIP # The megaship instance for easy global access.
var random : RandomNumberGenerator # Used for general randomness.

var prev_mouse_mode

signal user_paused(is_paused)



func _ready():
	# Setup stats.
	init_stats()
	stats.connect("stat_changed", self, "_on_stat_changed")
	
	# Init global randomizer.
	random = init_random()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("user_pause"):
		global.toggle_user_pause()
	# Set current input method.
	if input_type != INPUT_TYPES.KEY_MOUSE and (event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion):
		input_type = INPUT_TYPES.KEY_MOUSE
		set_touchscreen_layout_visibility(false)
	elif input_type != INPUT_TYPES.GAMEPAD and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		input_type = INPUT_TYPES.GAMEPAD
		set_touchscreen_layout_visibility(false)
	elif input_type != INPUT_TYPES.TOUCHSCREEN and (event is InputEventScreenDrag or event is InputEventScreenTouch):
		input_type = INPUT_TYPES.TOUCHSCREEN
		set_touchscreen_layout_visibility(true)
##	Debug gampead input.
#	if event is InputEventJoypadButton:
#		printt(event.button_index, event.pressed)
#	if event is InputEventJoypadMotion:
#		printt(event.axis, event.axis_value)
	if event.is_action_pressed("toggle_fullscreen"):
		# Toggle fullscreen	
		Config.toggle_fullscreen()
		Config.save()
	
	# Exit game function.
	if event.is_action_pressed("exit_game"):
		game_exit_timer.start()
	elif event.is_action_released("exit_game"):
		game_exit_timer.stop()



func _on_megaship_tree_exiting():
	MEGASHIP = null


func _on_game_exit_timer_timeout() -> void:
	exit_game()


func _on_stat_changed(stat_name: String, new_value: float) -> void:
	match stat_name:
		"one_ups": 
			if new_value > one_ups:
				snd_collect.play()
			one_ups = int(new_value)
		"e_tanks": 
			if new_value > e_tanks:
				snd_collect.play()
			e_tanks = int(new_value)


###################
### Global API. ###
###################


func pause() -> void:
	set_pause(true)


func unpause() -> void:
	set_pause(false)


func set_pause(value : bool) -> void:
	is_paused = value
	get_tree().paused = value


func set_user_pause(value : bool) -> void:
	# The user can only pause the game if it is not paused
	# or can unpause it if it is paused by him.
	if (user_pause or !is_paused) and MEGASHIP is Megaship:
		set_pause(value)
		user_pause = value
		emit_signal("user_paused", value)
		if value:
			prev_mouse_mode = Input.get_mouse_mode() 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(prev_mouse_mode)


func toggle_pause() -> void:
	set_pause(!is_paused)


func toggle_user_pause() -> void:
	set_user_pause(!is_paused)


func is_mobile_os(os = self.os):
	return os == "Android" or os == "iOS"


func create_touchscreen_layout(parent : Node = get_parent()):
	current_touchscreen_layout = TOUCHSCREEN_LAYOUT.instance()
	parent.call_deferred("add_child", current_touchscreen_layout)
	set_touchscreen_layout_visibility(input_type == INPUT_TYPES.TOUCHSCREEN)


func set_touchscreen_layout_visibility(value : bool):
	if current_touchscreen_layout != null:
		current_touchscreen_layout.visible = value


func game_over() -> void:
	# Placeholder for game_over scenario.
	# TODO: Reset points.
	init_stats()


func init_stats() -> void:
	stats.initialize()
	one_ups = stats.get_stat_initial_value("one_ups")
	e_tanks = stats.get_stat_initial_value("e_tanks")


func modify_stat(stat_name: String, ammount: float) -> void:
	stats.modify_stat(stat_name, ammount)


func exit_game() -> void:
	get_tree().quit()


##########################
### Library functions. ###
##########################


func init_random() -> RandomNumberGenerator:
	var random = RandomNumberGenerator.new()
	random.randomize()
	return random


func fix_mouse_mode() -> void:
	# This shit is a workaround for the mouse not being able to
	# leave a section of the screen when toggling fullscreen.
	var tmp = Input.get_mouse_mode()
	Input.set_mouse_mode(0)
	Input.set_mouse_mode(tmp)
	# Input.call_deferred("set_mouse_mode", Input.get_mouse_mode())

