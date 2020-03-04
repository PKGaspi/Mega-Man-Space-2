extends MenuPanel

onready var pager = get_node("MarginContainer/Pager")

func _ready() -> void:
	global.connect("user_pause", self, "_on_global_user_pause")
	opening_animation()
	
	# Load menu entries.
	update_entries()
	flickering_timer.start()

func _on_action_pressed_ui_left():
	previous_page()

func _on_action_pressed_ui_right():
	next_page()
	

func _on_action_pressed_ui_accept():
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
				global.MEGASHIP.set_weapon(pager.page_index * 6 + entry_index - 1, false)
				global.set_user_pause(false)
	
func _on_global_user_pause(value : bool) -> void:
	if !value:
		closing_animation()
		yield(self, "closed")
		queue_free()

func _on_FlickeringTimer_timeout() -> void:
	entry.modulate.a = 0 if entry.modulate.a == 1 else 1

func next_page() -> void:
	entry.modulate.a = 1
	pager.next_page()
	update_entries()

func previous_page() -> void:
	entry.modulate.a = 1
	pager.previous_page()
	update_entries()

func update_entries() -> void:
	entries = []
	n_entries = 0
	var page = pager.page_index
	
	for entry in pager.current_page.get_node("Letters").get_children():
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
