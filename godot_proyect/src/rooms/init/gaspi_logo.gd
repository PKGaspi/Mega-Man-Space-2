extends TextureRect

var n_shines: int = 2

onready var tween := $Tween
onready var timer := $Timer
onready var shine := $Shine

func _ready() -> void:
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2, Tween.TRANS_SINE, Tween.EASE_IN, .3)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.5, Tween.TRANS_SINE, Tween.EASE_IN, 3.7)
	tween.start()


func _on_Timer_timeout() -> void:
	shine.play()


func _on_Shine_animation_finished() -> void:
	n_shines -= 1
	if n_shines == 0:
		shine.stop()
