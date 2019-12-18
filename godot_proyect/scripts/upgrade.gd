extends KinematicBody2D

const SPR_SHELL_POS = preload("res://assets/sprites/upgrades/upgrade_shell_0.png")
const SPR_SHELL_NEG = preload("res://assets/sprites/upgrades/upgrade_shell_1.png")

const NEGATIVE_FREQUENCY = 1

const MOVE_SPEED_POS = 10
const MOVE_SPEED_NEG = 40

const SHINE_TIME_MIN = 2 # In seconds.
const SHINE_TIME_MAX = 5 # In seconds.

const INVENCIBILITY_TIME = .5 # In seconds.
const FLICKERING_INTERVAL = .05 # In seconds.

var bad = false

var max_hp = 70
var hp = max_hp
var invencibitity_timer = 0 # Seconds until this enemy can be hit again.
var flickering_timer = 0 # Seconds until a toggle on visibility is made.

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
	HP: 1,
	SPEED: .4,
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

var shine_time = 0 # Seconds for the next shine to happen.

var random

# TODO: Destroy upgrades after x seconds. <---- Esto lo ha escrito Álex.
func _ready():
	random = RandomNumberGenerator.new()
	random.seed *= OS.get_ticks_usec()
	
	
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
	var dir = global_position.direction_to(global.MEGASHIP.global_position)
	dir.normalized()
	var motion = dir * (MOVE_SPEED_NEG if bad else MOVE_SPEED_POS)
	move_and_slide(motion)
	
	for i in range(get_slide_count()):
		var collider = get_slide_collision(i).collider
		if collider == global.MEGASHIP:
			collider.upgrade(type, ammount)
			queue_free()
			break
			
func _process(delta):
	shine_time -= delta
	if !bad and shine_time <= 0:
		shine()
		shine_time = random.randf_range(SHINE_TIME_MIN, SHINE_TIME_MAX)
		
	# Calculate invencibility and filckering.
	invencibitity_timer = max(invencibitity_timer - delta, 0)
	if is_invincible():
		if flickering_timer <= 0:
			# Toggle flicker.
			toggle_visibility()
			flickering_timer = FLICKERING_INTERVAL
		else:
			flickering_timer = max(flickering_timer - delta, 0)
	else:
		# Stop at a visible state.
		set_visibility(true)

func shine():
	if !bad:
		$SprShine.frame = 0 # Shine.

func set_visibility(value):
	$SprIcon.visible = value
	$SprShell.visible = value
	$SprShine.visible = value
	
func toggle_visibility():
	$SprIcon.visible = !$SprIcon.visible
	$SprShell.visible = !$SprShell.visible
	$SprShine.visible = !$SprShine.visible

func toggle_upgrade():
	ammount = -ammount
	bad = !bad
	if bad:
		$SprShine.stop()
		$SprShell.texture = SPR_SHELL_NEG
		set_collision_layer_bit(2, true)
		set_collision_mask_bit(1, true)
		set_collision_mask_bit(4, false)
	else:
		$SprShine.play("shine")
		$SprShell.texture = SPR_SHELL_POS
		set_collision_layer_bit(2, false)
		set_collision_mask_bit(1, false)
		set_collision_mask_bit(4, true)
		
func hit(bullet):
	if !is_invincible():
		take_damage(bullet.damage)
	
func take_damage(damage):
	hp -= damage
	invencibitity_timer = INVENCIBILITY_TIME
	check_death()

func check_death():
	if hp <= 0:
		toggle_upgrade()

func is_invincible():
	return invencibitity_timer > 0