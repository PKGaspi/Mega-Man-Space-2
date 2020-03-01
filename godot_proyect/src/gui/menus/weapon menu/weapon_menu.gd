extends Control

const PALETTES : SpriteFrames = preload("res://resources/gui/menu_palettes.tres")

const OPENNING_TIME = .3

var unlocked_entries : Dictionary
var entries = []
var entry : Node
var entry_index : int = 1
var n_entries : int = 0

signal opened
signal closed

func _ready() -> void:
	global.connect("user_pause", self, "_on_global_user_pause")
	opening_animation()
	
	# Load menu entries.
	update_entries()
	$FlickeringTimer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		accept_event()
		next_entry()
	if event.is_action_pressed("ui_up"):
		accept_event()
		previous_entry()
	if event.is_action_pressed("ui_left"):
		accept_event()
		next_page()
	if event.is_action_pressed("ui_right"):
		accept_event()
		previous_page()
	if event.is_action_pressed("ui_accept"):
		accept_event()
		match entry_index:
			0:
				# Next page.
				next_page()
			7:
				# Use an e-tank.
				if global.MEGASHIP != null and global.etanks > 0:
					global.etanks -= 1
					global.MEGASHIP.call_deferred("set_hp", global.MEGASHIP.hp_max, true)
					global.set_user_pause(false)
			8:
				# TODO: Open settings menu.
				pass
			_:
				# Set weapon.
				if global.MEGASHIP != null and global.MEGASHIP.has_method("set_weapon"):
					global.MEGASHIP.set_weapon($MarginContainer/Pager.page_index * 6 + entry_index - 1, false)
					global.set_user_pause(false)

func _on_global_user_pause(value : bool) -> void:
	if !value:
		closing_animation()
		yield(self, "closed")
		queue_free()

func _on_FlickeringTimer_timeout() -> void:
	entry.modulate.a = 0 if entry.modulate.a == 1 else 1

func growing_animation(start_size: Vector2, final_size: Vector2, time: float = OPENNING_TIME):
	# Start opening animation.
	$Tween.interpolate_property(self, "rect_size", start_size, final_size, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "rect_position", rect_position + final_size / 2, rect_position + start_size / 2, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	# Animation is over.

func opening_animation(time = OPENNING_TIME):
	$MarginContainer.visible = false
	growing_animation(Vector2.ZERO, rect_size, time)
	yield($Tween, "tween_all_completed") # Wait until the animation is over.
	$MarginContainer.visible = true
	emit_signal("opened")

func closing_animation(time = OPENNING_TIME):
	$MarginContainer.visible = false
	growing_animation(rect_size, Vector2.ZERO, time)
	yield($Tween, "tween_all_completed") # Wait until the animation is over.
	$MarginContainer.visible = true
	emit_signal("closed")


func next_page() -> void:
	entry.modulate.a = 1
	$MarginContainer/Pager.next_page()
	update_entries()

func previous_page() -> void:
	entry.modulate.a = 1
	$MarginContainer/Pager.previous_page()
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
		var node = get_node("MarginContainer/Pager/Page" + str(page) + "/Info/" + entry.name)
		if key == Vector2(0, 7):
			# e-tank entry.
			entries.append(entry)
			for i in range(global.etanks, 4):
				node.get_node(str(i + 1)).visible = false
		elif key == Vector2(1, 7):
			# 1up entry.
			entries.append(null) # Make this entry non selectable.
			node.get_node("Text").text = ":  %02d" % global.lifes
		elif !unlocked_entries.has(Vector2(key)) or unlocked_entries[key]:
			# No info about current entry or entry is unlocked.
			entries.append(entry)
			if node != null and node.get("value") != null and global.MEGASHIP != null:
				var weapon_index = page * 6 + n_entries - 1
				node.palette = clamp(weapon_index, 0, Weapon.TYPES.ONE)
				node.value = global.MEGASHIP.get_ammo(weapon_index) if weapon_index > 0 else global.MEGASHIP.hp
		else:
			# Not unlocked. Hide this entry.
			entries.append(null)
			entry.modulate.a = 0
			if node != null:
				node.modulate.a = 0
		n_entries += 1
	entry = entries[entry_index]

func set_palette(value : int) -> void:
	if value < PALETTES.get_frame_count("default"):
		$Background.material.set_shader_param("palette", PALETTES.get_frame("default", value))
