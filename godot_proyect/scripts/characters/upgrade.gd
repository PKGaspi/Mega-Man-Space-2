extends "res://scripts/characters/pickable.gd"

const SPR_SHELL_POS = preload("res://assets/sprites/upgrades/upgrade_shell_0.png")
const SPR_SHELL_NEG = preload("res://assets/sprites/upgrades/upgrade_shell_1.png")

const NEGATIVE_FREQUENCY = .5

const MOVE_SPEED_POS = 10
const MOVE_SPEED_NEG = 40

const SHINE_TIME_MIN = 2 # In seconds.
const SHINE_TIME_MAX = 5 # In seconds.

var bad = false # Whether the upgrade is bad or good.

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
	N_SHOOTS: "n_cannons",
	BULLET_MAX: "bullet_max",
}

var UPGRADE_AMMOUNTS = {
	HP: 2,
	SPEED: .2,
	N_SHOOTS: 1,
	BULLET_MAX: 1,
}

var UPGRADE_SPRITES = {
	HP: preload("res://assets/sprites/upgrades/upgrade_icon_hp.png"),
	SPEED: preload("res://assets/sprites/upgrades/upgrade_icon_speed.png"),
	N_SHOOTS: preload("res://assets/sprites/upgrades/upgrade_icon_cannons.png"),
	BULLET_MAX: preload("res://assets/sprites/upgrades/upgrade_icon_bullets.png"),
}

var type
var ammount
var sprite = preload("res://assets/sprites/megaship/lemon.png")

func _ready():
	
	# Set upgrade type.
	var index = random.randi_range(0, ENUM_LENGTH - 1)
	type = UPGRADE_TYPES[index]
	ammount = UPGRADE_AMMOUNTS[index]
	$SprIcon.texture = UPGRADE_SPRITES[index]
	
	# Maybe this upgrade is negative.
	if random.randf() <= NEGATIVE_FREQUENCY:
		# The upgrade is bad.
		toggle_upgrade()
	else:
		# The upgrade is good.
		# Shine for the first time.
		$SprShine.play("shine")
		hp_bar.visible = false # Hide hp bar if good.
		

#########################
## Auxiliar functions. ##
#########################

func shine():
	$SprShine.frame = 0 # Shine.
	if !bad:
		$SprShine.play("default")
		$ShineTimer.start(random.randf_range(SHINE_TIME_MIN, SHINE_TIME_MAX))
	else:
		$SprShine.stop()

func toggle_upgrade():
	ammount = -ammount
	bad = !bad
	set_collision_layer_bit(2, bad)
	$LifeTimer.start(life_time)
	$LifeFlickeringTimer.start(life_flicker_time)
	hp_bar.visible = bad # Hide hp bar if good.
	flickering = false
	if bad:
		to_follow = global.MEGASHIP
		to_follow.connect("tree_exiting", self, "_on_to_follow_tree_exiting")
		$SprShine.stop()
		$Sprite.texture = SPR_SHELL_NEG
		move_speed = MOVE_SPEED_NEG
	else:
		to_follow = null
		$SprShine.play("shine")
		$Sprite.texture = SPR_SHELL_POS
		move_speed = MOVE_SPEED_POS

func die():
	life_timer = 0 # Reset life_timer.
	hp = hp_max
	toggle_upgrade()
	
func collide(collider):
	collider.upgrade(type, ammount)
	if bad:
		.collide(collider)
	queue_free()

func _on_shine_timer_timeout() -> void:
	shine()
