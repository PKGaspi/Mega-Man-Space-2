extends Area2D

enum {
	HP,
	SPEED,
	N_SHOOTS,
	BULLET_MAX,
	ENUM_LENGTH,
}

var UPGRADE_TYPES = {
	HP: "hp_max",
	SPEED: "speed_multiplier",
	N_SHOOTS: "n_shoots",
	BULLET_MAX: "bullet_max",
}

var type
var ammount
var sprite = preload("res://assets/sprites/megaship/lemon.png")

func _ready():
	var random = RandomNumberGenerator.new()
	random.seed *= OS.get_ticks_usec()
	
	connect("body_entered", self, "_on_body_entered")
	var index =  random.randi_range(0, ENUM_LENGTH - 1)
	type = UPGRADE_TYPES[index]
	
	print(type)
	#type = UPGRADE_TYPES[N_SHOOTS]
	ammount = 1
	#$Sprite.texture = UPGRADE_SPRITES[index]

func _on_body_entered(body):
	if body == global.MEGASHIP:
		body.upgrade(type, ammount)
		queue_free()