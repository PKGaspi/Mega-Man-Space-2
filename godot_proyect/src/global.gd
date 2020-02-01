extends Node

const CURSOR = preload("res://assets/sprites/gui/cursor.png")
const TOUCHSCREEN_LAYOUT = preload("res://src/gui/touchscreen_layout.tscn")
const SCREEN_SIZE = Vector2(480, 270)

const EXITING_TIME = .3 # In seconds.
var exiting_timer = 0 # Time that the exit key has been pressed.

var is_paused : bool = false
var user_pause : bool = false
var os : String = OS.get_name()

var current_touchscreen_layout = null

enum INPUT_TYPES {
	KEY_MOUSE,
	GAMEPAD,
	TOUCHSCREEN,
}

var input_type : int # Wheter the game is being played with a gamepad or a keyboard.

# Weapons.
enum WEAPONS {
	MEGA,
	BUBBLE,
	AIR,
	QUICK,
	HEAT,
	WOOD,
	METAL,
	FLASH,
	CRASH,
	SIZE,
}

const LIFES_DEFAULT = 2
var lifes = LIFES_DEFAULT # The number of extra lifes.
const MAX_LIFES = 9
const ETANKS_DEFAULT = 0
var etanks = 0 # The number of extra lifes.
const MAX_ETANKS = 4

var MEGASHIP # The megaship instance for easy global access.
var random : RandomNumberGenerator # Used for general randomness.

signal user_pause

func _ready():
	random = init_random()
	pause_mode = Node.PAUSE_MODE_PROCESS
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	

func _input(event: InputEvent) -> void:
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
		toggle_fullscreen()
	
	# Exit game function.
	if event.is_action_pressed("exit_game"):
		user_pause_toggle()
		$GameExitTimer.start(EXITING_TIME)
	if event.is_action_released("exit_game"):
		$GameExitTimer.stop()
	
func _on_megaship_tree_exiting():
	MEGASHIP = null

func _on_game_exit_timer_timeout() -> void:
	exit_game()

##########################
### Library functions. ###
##########################

func pause() -> void:
	set_pause(true)

func unpause() -> void:
	set_pause(false)
	
func set_pause(value) -> void:
	is_paused = value
	get_tree().paused = value
	
func pause_toggle() -> void:
	set_pause(!is_paused)

func user_pause_toggle() -> void:
	# The user can only pause the game if it is not paused
	# or if it is paused by him.
	if user_pause or !is_paused: 
		# TODO: Toggle menus and play sounds.
		pause_toggle()
		user_pause = is_paused
		emit_signal("user_pause", is_paused)
		if is_paused:
			$SndPauseMenu.play()

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
	lifes = LIFES_DEFAULT
	etanks = ETANKS_DEFAULT
	# TODO: Load game over scene.

func exit_game() -> void:
	get_tree().quit()

func create_empty_image(size : Vector2) -> ImageTexture:
	var empty_image = Image.new()
	var empty_texture = ImageTexture.new()
	empty_image.create(size.x, size.y, false, Image.FORMAT_BPTC_RGBA)
	empty_texture.create_from_image(empty_image)
	return empty_texture
	
func create_timer(name : String) -> Timer:
	var timer = Timer.new()
	timer.name = name
	return timer
	
func init_random():
	var random = RandomNumberGenerator.new()
	random.randomize()
	return random
	
func toggle_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen
	fix_mouse_mode()

func fix_mouse_mode():
	# This shit is a workaround for the mouse not being able to
	# leave a section of the screen when toggling fullscreen.
	var tmp = Input.get_mouse_mode()
	Input.set_mouse_mode(0)
	Input.set_mouse_mode(tmp)

func obtain_1up():
	# TODO: play 1up sound.
	lifes = min(lifes + 1, MAX_LIFES)
	
func obtain_etank():
	# TODO: play e-tank sound.
	etanks = min(etanks + 1, MAX_ETANKS)

func play_audio_random_pitch(snd, interval):
	if snd != null and snd.has_method("play"):
		snd.play(0)
		snd.pitch_scale = random.randf_range(interval.x, interval.y)
