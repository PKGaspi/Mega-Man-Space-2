extends MenuPanel

onready var enemy_generator_path = "/root/Space/GameLayer/EnemyGenerator"

func _on_action_pressed_ui_accept():
	match entry_index:
		0:
			if !has_node(enemy_generator_path):
				return
			var enemy_generator = get_node(enemy_generator_path)
			var ship = global.MEGASHIP
			if global.MEGASHIP is Megaship and enemy_generator != null and enemy_generator.get("center") != null:
				ship.global_position = enemy_generator.center
		1:
			if global.MEGASHIP is Megaship:
				for weapon in global.unlocked_weapons:
					global.unlocked_weapons[weapon] = true
		
		2:
			if global.MEGASHIP is Megaship:
				global.MEGASHIP.die()
				
		_:
			print_debug("Not implemented")

func _on_global_user_pause(value: bool) -> void:
	pass
