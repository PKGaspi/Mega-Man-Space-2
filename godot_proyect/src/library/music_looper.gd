extends Node

export var intro: AudioStream setget set_intro
export var loop: AudioStream setget set_loop

export var playing:= false setget set_playing
export var autoplay:= false

onready var intro_node:= get_node("MusicIntro")
onready var loop_node:= get_node("MusicLoop")

signal intro_finished

func _ready() -> void:
	set_intro(intro)
	set_loop(loop)
	if autoplay:
		call_deferred("play")

func _on_MusicIntro_finished() -> void:
	emit_signal("intro_finished")
	play_loop()

func set_playing(value: bool):
	if value:
		play()
	else:
		stop()

func play():
	if intro != null:
		intro_node.play()
	elif loop != null:
		loop_node.play()

func play_loop():
	loop_node.play()

func stop():
	intro_node.stop()
	loop_node.stop()

func set_intro(value: AudioStream) -> void:
	intro = value
	if is_inside_tree():
		intro_node.stream = value

func set_loop(value: AudioStream) -> void:
	loop = value
	if is_inside_tree():
		loop_node.stream = value

