extends Node


onready var title := $Control/Dialogue/MarginContainer/VBoxContainer/Title
onready var message := $Control/Dialogue/MarginContainer/VBoxContainer/Message
onready var button := $Control/Dialogue/MarginContainer/VBoxContainer/FeedbackButton

onready var letter_timer := $LetterTimer
onready var between_timer := $BetweenTimer

onready var fields := [title, message]
var current_field := -1


func _ready() -> void:
	GameStats.save()
	title.visible_characters = 0
	message.visible_characters = 0
	button.visible = false


func _on_BetweenTimer_timeout() -> void:
	current_field += 1
	letter_timer.start()
	if current_field >= len(fields):
		letter_timer.stop()
		button.visible = true


func _on_LetterTimer_timeout() -> void:
	if current_field < 0 or current_field >= len(fields):
		return
	
	fields[current_field].visible_characters += 1
	if fields[current_field].percent_visible >= 1:
		between_timer.start()
		letter_timer.stop()
