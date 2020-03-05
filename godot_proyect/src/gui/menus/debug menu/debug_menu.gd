extends MenuPanel

onready var enemy_generator = get_node("/root/Space/GameLayer/EnemyGenerator")


func _on_action_pressed_ui_accept():
	match entry_index:
		0:
			var ship = global.MEGASHIP
			if global.MEGASHIP is Megaship and enemy_generator.get("center") != null:
				ship.global_position = enemy_generator.center
		1:
			if global.MEGASHIP is Megaship:
				for weapon in global.MEGASHIP.unlocked_weapons:
					global.MEGASHIP.unlocked_weapons[weapon] = true
				
		_:
			print_debug("Not implemented")

func _on_global_user_pause(value : bool) -> void:
	set_active(!value)

func update_entries() -> void:
	entries.clear()
	n_entries = 0
	for entry in get_children():
		entries.append(entry)
		n_entries += 1
	set_entry(entry_index)
