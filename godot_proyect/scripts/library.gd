extends Node

var random

func _ready():
	random = RandomNumberGenerator.new()
	random.seed *= OS.get_ticks_usec()


func play_audio_random_pitch(snd, interval):
	snd.play(0)
	snd.pitch_scale = random.randi_range(interval.x, interval.y)