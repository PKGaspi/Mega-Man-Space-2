extends MarginContainer


onready var tween := $Tween

func _ready() -> void:
	pass


func animate() -> void:
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), .5, Tween.TRANS_SINE, Tween.EASE_IN, .3)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, Tween.TRANS_SINE, Tween.EASE_IN, 6.3)
	tween.start()
