extends Control

onready var enemy_generator = get_node("/root/Space/GameLayer/EnemyGenerator")

var active = false setget set_active

var entry_index:= 0 setget set_entry
var entries: Array
var n_entries:= 0

func _ready() -> void:
	update_entries()

func _input(event: InputEvent) -> void:
	if active:
		if event.is_action_pressed("ui_down"):
			accept_event()
			next_entry()
		if event.is_action_pressed("ui_up"):
			accept_event()
			previous_entry()
		if event.is_action_pressed("ui_accept"):
			accept_event()
			match entry_index:
				0:
					var ship = global.MEGASHIP
					if global.MEGASHIP is Megaship and enemy_generator.get("center") != null:
						ship.global_position = enemy_generator.center
				_:
					print_debug("Not implemented")

func update_entries() -> void:
	entries.clear()
	n_entries = 0
	for entry in get_children():
		entries.append(entry)
		n_entries += 1
	set_entry(entry_index)

func set_active(value: bool) -> void:
	active = value

func set_entry(value: int) -> void:
	entries[entry_index].modulate = Color.white
# warning-ignore:narrowing_conversion
	entry_index = clamp(value, 0, n_entries)
	entries[entry_index].modulate = Color.blueviolet

func previous_entry() -> void:
	set_entry(entry_index - 1 if entry_index > 0 else n_entries - 1)
	
func next_entry() -> void:
	set_entry((entry_index + 1) % n_entries)
