class_name MenuPanel
extends Control

const PALETTES : SpriteFrames = preload("res://resources/gui/menu_palettes.tres")

var tween = Tween.new()
var flickering_timer = Timer.new()
export var _selected_flickering_interval: float = 8.0/60.0
export var opening_time: = .3
export var hide_when_animating: NodePath
export var background: NodePath = "Background"
export var palette: int = 0 setget set_palette

var active:= true setget set_active
export(Array, NodePath) var entries
var entry: Node
export var entry_index: int = 0
var n_entries: int = 0

export var snd_selection_change: NodePath = "SndMenuSelect"

signal opened
signal closed
signal animation_ended

func _ready() -> void:
	# Setup tween.
	add_child(tween)
	# Setup flickering timer.
	add_child(flickering_timer)
	flickering_timer.wait_time = _selected_flickering_interval
	flickering_timer.connect("timeout", self, "_on_FlickeringTimer_timeout")
	flickering_timer.start()
	
	# Connect global pause.
	global.connect("user_pause", self, "_on_global_user_pause")
	
	# Animate opening.
	opening_animation()
	
	# Update current entires.
	call_deferred("update_entries")
	
func _input(event: InputEvent) -> void:
	if active:
		if event.is_action_pressed("ui_down"):
			accept_event()
			_on_action_pressed_ui_down()
		elif event.is_action_pressed("ui_up"):
			accept_event()
			_on_action_pressed_ui_up()
		elif event.is_action_pressed("ui_left"):
			accept_event()
			_on_action_pressed_ui_left()
		elif event.is_action_pressed("ui_right"):
			accept_event()
			_on_action_pressed_ui_right()
		elif event.is_action_pressed("ui_accept"):
			accept_event()
			_on_action_pressed_ui_accept()

func _on_action_pressed_ui_down():
	next_entry()
	
func _on_action_pressed_ui_up():
	previous_entry()

func _on_action_pressed_ui_left():
	pass

func _on_action_pressed_ui_right():
	pass
	
func _on_action_pressed_ui_accept():
	pass

func _on_FlickeringTimer_timeout() -> void:
	entry.modulate.a = 0 if entry.modulate.a == 1 else 1

func _on_global_user_pause(value : bool) -> void:
	if !value:
		close_menu()

func growing_animation(start_size: Vector2, final_size: Vector2, time: float = opening_time, hide:= get_node(hide_when_animating)):
	if hide != null: hide.visible = false
	# Start opening animation.
	tween.interpolate_property(self, "rect_size", start_size, final_size, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rect_position", rect_position + final_size / 2, rect_position + start_size / 2, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed") # Wait until the animation is over.
	# Animation is over.
	if hide != null: hide.visible = true
	emit_signal("animation_ended")

func opening_animation(time = opening_time):
	growing_animation(Vector2.ZERO, rect_size, time)
	yield(self, "animation_ended")
	emit_signal("opened")

func closing_animation(time = opening_time):
	growing_animation(rect_size, Vector2.ZERO, time)
	yield(self, "animation_ended")
	emit_signal("closed")

func close_menu():
	closing_animation()
	yield(self, "closed")
	queue_free()

func set_entry(value : int, play_sound: bool = true) -> bool:
# warning-ignore:narrowing_conversion
	value = clamp(value, 0, n_entries)
	if value < entries.size():
		if play_sound and snd_selection_change != null: get_node(snd_selection_change).play()
		if entry != null:
			entry.modulate.a = 1
		entry_index = value
		entry = get_node(entries[entry_index]) if entries[entry_index] is NodePath else entries[entry_index]
		return true
	return false

func set_active(value: bool) -> void:
	active = value
	if active:
		flickering_timer.start()
	else:
		flickering_timer.stop()
		entry.modulate.a = 1

func next_entry() -> void:
	if n_entries != 0:
		var new_entry = (entry_index + 1) % n_entries
		while entries[new_entry] == null:
			new_entry = (new_entry + 1) % n_entries
		set_entry(new_entry)
	
func previous_entry() -> void:
	if n_entries != 0:
		var new_entry = (entry_index - 1) % n_entries if entry_index > 0 else n_entries - 1
		while entries[new_entry] == null:
			new_entry = (new_entry - 1) % n_entries if new_entry > 0 else n_entries - 1
		set_entry(new_entry)

func update_entries() -> void:
	n_entries = len(entries)
# warning-ignore:narrowing_conversion
	entry_index = clamp(entry_index, 0, n_entries - 1)
	entry = get_node(entries[entry_index])

func set_palette(value : int) -> void:
	if value < PALETTES.get_frame_count("default"):
		palette = value
		get_node(background).material.set_shader_param("palette", PALETTES.get_frame("default", value))
