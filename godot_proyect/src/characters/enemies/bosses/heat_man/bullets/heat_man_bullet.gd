extends Bullet

onready var cannons := $CannonSetup

func disappear() -> void:
	# Create mini bullets when exploding.
	cannons.fire()
	.disappear()
