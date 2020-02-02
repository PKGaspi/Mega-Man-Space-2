extends Control

var entries = []
var entry : Node
var entry_index : int = 0
var n_entries : int = 0

func _ready() -> void:
	update_entries()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if entry_index == 0:
			next_page()
		else:
			global.set_user_pause(false)
			queue_free()
	if event.is_action_pressed("ui_down"):
		next_entry()
	if event.is_action_pressed("ui_up"):
		previous_entry()

func next_page() -> void:
	entry.modulate.a = 1
	$MarginContainer/Pager.next_page()
	update_entries()

func set_entry(value : int) -> void:
	$SndMenuSelect.play()
	entry.modulate.a = 1
	entry_index = clamp(value, 0, n_entries)
	entry = entries[entry_index]

func next_entry() -> void:
	set_entry((entry_index + 1) % n_entries)
	
func previous_entry() -> void:
	set_entry((entry_index - 1) % n_entries)

func update_entries() -> void:
	entries = []
	n_entries = 0
	for entry in $MarginContainer/Pager.current_page.get_node("Letters").get_children():
		entries.append(entry)
		n_entries += 1
	entry = entries[entry_index]


func _on_FlickeringTimer_timeout() -> void:
	entry.modulate.a = 0 if entry.modulate.a == 1 else 1
	pass # Replace with function body.
