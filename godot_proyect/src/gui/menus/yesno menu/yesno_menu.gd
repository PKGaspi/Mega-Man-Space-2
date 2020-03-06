extends MenuPanel

export var title:= "Are you sure?" setget set_title
onready var title_node:= get_node("Contents/Sections/Title")

signal actioned(result)

func _ready() -> void:
	pass

func _on_action_pressed_ui_left():
	play_sound(snd_ui_left)
	previous_entry()
	
func _on_action_pressed_ui_right():
	play_sound(snd_ui_right)
	next_entry()

func _on_action_pressed_ui_accept():
	match entry_index:
		0: # Yes.
			emit_signal("actioned", true)
			close_menu()
		1: # No.
			emit_signal("actioned", false)
			close_menu()

func _on_action_pressed_ui_cancel():
	emit_signal("actioned", false)

func set_title(value: String) -> void:
	title_node.text = value
