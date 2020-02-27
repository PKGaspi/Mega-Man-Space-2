extends Control

const PALETTES : SpriteFrames = preload("res://resources/gui/menu_palettes.tres")

const OPENNING_TIME = .3

var unlocked_entries : Dictionary
var entries = []
var entry : Node
var entry_index : int = 1
var n_entries : int = 0

var prev_mouse

signal opened

func _ready() -> void:
	prev_mouse = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Start opening animation.
	$MarginContainer.visible = false
	$Tween.interpolate_property(self, "rect_size", Vector2.ZERO, rect_size, OPENNING_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "rect_position", rect_position + rect_size / 2, rect_position, OPENNING_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed") # Wait until the animation is over.
	$MarginContainer.visible = true
	# Animation is over.
	
	# Load menu entries.
	update_entries()
	global.connect("user_pause", self, "_on_global_user_pause")
	$FlickeringTimer.start()
	emit_signal("opened")

func _exit_tree() -> void:
	Input.set_mouse_mode(prev_mouse)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		accept_event()
		match entry_index:
			0:
				# Next page.
				next_page()
			7:
				# TODO: E-tank or 1up.
				pass
			8:
				# TODO: Open settings menu.
				pass
			_:
				# Set weapon.
				if global.MEGASHIP != null and global.MEGASHIP.has_method("set_weapon"):
					global.MEGASHIP.set_weapon($MarginContainer/Pager.page_index * 6 + entry_index - 1, false)
					global.set_user_pause(false)
	if event.is_action_pressed("ui_down"):
		accept_event()
		next_entry()
	if event.is_action_pressed("ui_up"):
		accept_event()
		previous_entry()

func _on_global_user_pause(value : bool) -> void:
	if !value:
		queue_free()

func _on_FlickeringTimer_timeout() -> void:
	entry.modulate.a = 0 if entry.modulate.a == 1 else 1

func next_page() -> void:
	entry.modulate.a = 1
	$MarginContainer/Pager.next_page()
	update_entries()

func set_entry(value : int, play_sound: bool = true) -> void:
# warning-ignore:narrowing_conversion
	value = clamp(value, 0, n_entries)
	if value < entries.size():
		if play_sound: $SndMenuSelect.play()
		if entry != null:
			entry.modulate.a = 1
		entry_index = value
		entry = entries[entry_index]

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
	entries = []
	n_entries = 0
	var page = $MarginContainer/Pager.page_index
	for entry in $MarginContainer/Pager.current_page.get_node("Letters").get_children():
		var key = Vector2(page, n_entries)
		if !unlocked_entries.has(Vector2(key)) or unlocked_entries[key]:
			# No info about current entry or entry is unlocked.
			entries.append(entry)
		else:
			# Not unlocked.
			entries.append(null)
			entry.modulate.a = 0
		n_entries += 1
	entry = entries[entry_index]

func set_palette(value : int) -> void:
	if value < PALETTES.get_frame_count("default"):
		$Background.material.set_shader_param("palette", PALETTES.get_frame("default", value))
