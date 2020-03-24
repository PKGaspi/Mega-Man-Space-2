class_name RandomPitchAudioStreamPlayer2D
extends AudioStreamPlayer2D

export var randomness_interval:= Vector2(1.0, 1.0)

var rng := global.init_random()



func play(from_position: float = 0.0) -> void:
	pitch_scale = rng.randf_range(randomness_interval.x, randomness_interval.y)
	.play(from_position)
