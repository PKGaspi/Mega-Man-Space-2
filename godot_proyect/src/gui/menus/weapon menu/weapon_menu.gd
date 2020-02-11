extends Control

const PALETTES : SpriteFrames = preload("res://resources/gui/menu_palettes.tres")

var entries = []
var entry : Node
var entry_index : int = 1
var n_entries : int = 0

func _ready() -> void:
	update_entries()
	global.connect("user_pause", self, "_on_global_user_pause")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if entry_index == 0:
			# Next page.
			next_page()
		elif entry_index == 7:
			# TODO: E-tank or 1up.
			pass
		else:
			# Set weapon.
			global.MEGASHIP.set_weapon($MarginContainer/Pager.page_index * 6 + entry_index - 1, false)
			global.set_user_pause(false)
	if event.is_action_pressed("ui_down"):
		next_entry()
	if event.is_action_pressed("ui_up"):
		previous_entry()

func _on_global_user_pause(value : bool) -> void:
	if !value:
		queue_free()

func _on_FlickeringTimer_timeout() -> void:
	entry.modulate.a = 0 if entry.modulate.a == 1 else 1
	pass # Replace with function body.

func next_page() -> void:
	entry.modulate.a = 1
	$MarginContainer/Pager.next_page()
	update_entries()

func set_entry(value : int) -> void:
	$SndMenuSelect.play()
	if entry != null:
		entry.modulate.a = 1
# warning-ignore:narrowing_conversion
	entry_index = clamp(value, 0, n_entries)
	entry = entries[entry_index]

func next_entry() -> void:
	set_entry((entry_index + 1) % n_entries)
	
func previous_entry() -> void:
	set_entry((entry_index - 1) % n_entries if entry_index > 0 else n_entries - 1)

func update_entries() -> void:
	entries = []
	n_entries = 0
	for entry in $MarginContainer/Pager.current_page.get_node("Letters").get_children():
		entries.append(entry)
		n_entries += 1
	entry = entries[entry_index]

func set_palette(value : int) -> void:
	if value < PALETTES.get_frame_count("default"):
		$Background.material.set_shader_param("palette", PALETTES.get_frame("default", value))
