extends Node

const FONT = preload("res://other/font.tres")
const CURSOR = preload("res://assets/sprites/gui/cursor.png")
const SCREEN_SIZE = Vector2(480, 270)

const EXITING_TIME = .3 # In seconds.
var exiting_timer = 0 # Time that the exit key has been pressed.

var pause = false

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

var MEGASHIP # The megaship instance for easy global access.
var gamepad 	: bool # Wheter the game is being played with a gamepad or a keyboard.
var random 		: RandomNumberGenerator # Used for general randomness.

func _ready():
	random = init_random()
	pause_mode = Node.PAUSE_MODE_PROCESS
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		# Toggle fullscreen	
		toggle_fullscreen()
	# Exit game function.
	if Input.is_action_pressed("exit_game"):
		if exiting_timer >= EXITING_TIME:
			get_tree().quit()
		exiting_timer += delta
	else:
		exiting_timer = max(exiting_timer - delta, 0)
		
##########################
### Library functions. ###
##########################

func create_empty_image(size : Vector2) -> ImageTexture:
	var empty_image = Image.new()
	var empty_texture = ImageTexture.new()
	empty_image.create(size.x, size.y, false, Image.FORMAT_BPTC_RGBA)
	empty_texture.create_from_image(empty_image)
	return empty_texture
	
func init_random():
	var random = RandomNumberGenerator.new()
	random.seed = random.seed * OS.get_ticks_usec()
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

func is_on_screen(viewport : Viewport, pos : Vector2) -> bool:
	var screen = viewport.get_visible_rect()
	return screen.has_point(pos)
	

func play_audio_random_pitch(snd, interval):
	snd.play(0)
	snd.pitch_scale = random.randf_range(interval.x, interval.y)