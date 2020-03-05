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
