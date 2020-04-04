class_name MusicLooper
extends Node

export var intro: AudioStream setget set_intro
export var loop: AudioStream setget set_loop

export var playing:= false setget set_playing
export var autoplay:= false

onready var intro_node: AudioStreamPlayer
onready var loop_node: AudioStreamPlayer

signal intro_finished


func _ready() -> void:
	# Setup nodes.
	intro_node = AudioStreamPlayer.new()
	loop_node = AudioStreamPlayer.new()
	intro_node.name = "MscIntro"
	loop_node.name = "MscLoop"
	intro_node.connect("finished", self, "_on_intro_finished")
	add_child(intro_node)
	add_child(loop_node)
	
	# Setup music.
	set_intro(intro)
	set_loop(loop)
	if autoplay:
		call_deferred("play")


func _on_intro_finished() -> void:
	# Only play loop if the intro has finished.
	if intro_node.get_playback_position() >= intro_node.stream.get_length():
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


