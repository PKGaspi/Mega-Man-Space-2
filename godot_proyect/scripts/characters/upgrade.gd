extends "res://scripts/characters/character.gd"

const SPR_SHELL_POS = preload("res://assets/sprites/upgrades/upgrade_shell_0.png")
const SPR_SHELL_NEG = preload("res://assets/sprites/upgrades/upgrade_shell_1.png")

const NEGATIVE_FREQUENCY = .5

const MOVE_SPEED_POS = 10
const MOVE_SPEED_NEG = 40

const SHINE_TIME_MIN = 2 # In seconds.
const SHINE_TIME_MAX = 5 # In seconds.

const INVENCIBILITY_TIME = .5 # In seconds.
const FLICKERING_INTERVAL = .05 # In seconds.
var shine_timer = 0 # Seconds for the next shine to happen.

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

var random

func _ready():
	random = global.init_random()
	
	# Set upgrade type.
	var index = random.randi_range(0, ENUM_LENGTH - 1)
	type = UPGRADE_TYPES[index]
	ammount = UPGRADE_AMMOUNTS[index]
	$SprIcon.texture = UPGRADE_SPRITES[index]
	
	# Maybe this upgrade is negative.
	if random.randf() <= NEGATIVE_FREQUENCY:
		toggle_upgrade()
	else:
		# Shine for the first time.
		$SprShine.play("shine")
		
func _physics_process(delta):
	# Move towards the Mega Ship.
	var dir = global_position.direction_to(global.MEGASHIP.global_position)
	dir.normalized()
	var motion = dir * (MOVE_SPEED_NEG if bad else MOVE_SPEED_POS)
	move_and_slide(motion)
	
	# Check for Mega Ship collision.
	for i in range(get_slide_count()):
		var collider = get_slide_collision(i).collider
		if collider == global.MEGASHIP:
			collider.upgrade(type, ammount)
			queue_free()
			break
			
func _process(delta):
	# Decrement shine timer
	shine_timer -= delta
	if !bad and shine_timer <= 0:
		shine()
		shine_timer = random.randf_range(SHINE_TIME_MIN, SHINE_TIME_MAX)
		

#########################
## Auxiliar functions. ##
#########################

func shine():
	if !bad:
		$SprShine.frame = 0 # Shine.

func toggle_upgrade():
	ammount = -ammount
	bad = !bad
	if bad:
		$SprShine.stop()
		$SprShell.texture = SPR_SHELL_NEG
		set_collision_layer_bit(2, true)
		set_collision_mask_bit(1, true)
	else:
		$SprShine.play("shine")
		$SprShell.texture = SPR_SHELL_POS
		set_collision_layer_bit(2, false)
		set_collision_mask_bit(1, false)
		
func die():
	life_timer = 0 # Reset life_timer.
	hp = hp_max
	toggle_upgrade()