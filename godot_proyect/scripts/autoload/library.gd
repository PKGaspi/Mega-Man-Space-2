extends Node

var random

func _ready():
	random = RandomNumberGenerator.new()
	random.seed *= OS.get_ticks_usec()

func toggle_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen
	var tmp = Input.get_mouse_mode()
	Input.set_mouse_mode(tmp - 1)
	Input.set_mouse_mode(tmp)

func play_audio_random_pitch(snd, interval):
	snd.play(0)
	snd.pitch_scale = random.randf_range(interval.x, interval.y)