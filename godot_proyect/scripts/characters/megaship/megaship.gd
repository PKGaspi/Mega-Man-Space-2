extends "res://scripts/characters/character.gd"

################
## Resources. ##
################
const CHARACTER = preload("res://scripts/characters/character.gd")

const LEMON = preload("res://scenes/characters/megaship/lemon.tscn")
const MASK = preload("res://assets/sprites/megaship/megaship_mask.png")
export(SpriteFrames) var palettes = null

onready var GUILAYER = $"/root/Space/GUILayer"
# Bars.
const PROGRESS_BAR = preload("res://scenes/gui/progress_bar.tscn")
const BAR_CELL_SIZE = Vector2(7, 2)
# Health Bar.
const HP_BAR_POS = Vector2(16, 24)
var hp_bar
# Ammo Bar.
const AMMO_BAR_POS = Vector2(23, 24)
var ammo_bar

######################
## Gameplay values. ##
######################
# Moving speed.
const MOVE_SPEED_ACCEL = 30 # In pixels/second^2.
const MOVE_SPEED_DEACCEL = 20 # In pixels/second^2.
const MOVE_SPEED_MAX = 260 # In pixels/second.
# Cannons positions.
const CANNON_CENTRE_POS = Vector2(15, -.5)
const CANNON_LEFT_POS = Vector2(7, 4)
const CANNON_RIGHT_POS = Vector2(7, -5)

# Auto fire cooldown. Maybe do this a variable so
# you can get upgrades to improve it.
const AUTO_FIRE_INTERVAL = .05 # In seconds/bullet.

const JOYSTICK_DEADZONE = .3

var mouse_pos
var mouse_last_pos

###########################
# Upgrades and atributes. #
###########################
# Speed.
const SPEED_MULTIPLIER_MAX = 1.8 # Max speed multiplier.
var speed_multiplier = 1 # This applies to max speed and accelerations.
const SPEED_MULTIPLIER_MIN = .6 # Min speed multiplier.
# HP.
const HP_MAX_MAX = 38 # Max max HP.
# var hp_max = 28 # Max HP. This is in character.gd.
const HP_MAX_MIN = 18 # Min max HP.
# Ammo.
const AMMO_MAX_MAX = 38 # Max max ammo.
var ammo_max = 28 # Max ammo.
const AMMO_MAX_MIN = 18 # Min max ammo.
# Cannons.
const N_CANNONS_MAX = 3 # Max number of active cannons.
var n_cannons = 1 # Number of active cannons.
const N_CANNONS_MIN = 1 # Min number of active cannons.
# Bullets.
const BULLET_MAX_MAX = 10 # Max max bullets per cannon on screen.
var bullet_max = 3 # Max bullets per cannon on screen.
const BULLET_MAX_MIN = 1 # Min max bullets per cannon on screen.

###########
# WEAPONS. #
###########
var WEAPONS = global.WEAPONS # WEAPONS enum.
var active_weapon = WEAPONS.MEGA # Current active weapon.
# Unlocked WEAPONS.
var unlocked_WEAPONS = {
	WEAPONS.MEGA : true,
	WEAPONS.BUBBLE : true,
	WEAPONS.AIR : true,
	WEAPONS.QUICK : true,
	WEAPONS.HEAT : true,
	WEAPONS.WOOD : true,
	WEAPONS.METAL : true,
	WEAPONS.FLASH : true,
	WEAPONS.CRASH : true,
}

##############
# HP & ammo. #
##############
# var hp = hp_max # Current HP. This is in character.gd.
var ammo = { # Current ammo for each weapon.
	WEAPONS.MEGA : ammo_max,
	WEAPONS.BUBBLE : ammo_max,
	WEAPONS.AIR : ammo_max,
	WEAPONS.QUICK : ammo_max,
	WEAPONS.HEAT : ammo_max,
	WEAPONS.WOOD : ammo_max,
	WEAPONS.METAL : ammo_max,
	WEAPONS.FLASH : ammo_max,
	WEAPONS.CRASH : ammo_max,
}

########################
# Mechanics variables. #
########################
var auto_fire = 0 # Seconds since last fire.
var speed = 0 # Speed at this frame.
var motion_dir = Vector2() # Direction of the last movement.

func _ready():
	global.MEGASHIP = self # Set global reference.
	connect("death", $"/root/Space", "_on_megaship_death")
	connect("tree_exiting", global, "_on_megaship_tree_exiting")
	
	# Init HP bar.
	hp_bar = PROGRESS_BAR.instance()
	hp_bar.init(BAR_CELL_SIZE, HP_BAR_POS, hp_max)
	GUILAYER.add_child(hp_bar)
	# Init Ammo bar.
	ammo_bar = PROGRESS_BAR.instance()
	ammo_bar.init(BAR_CELL_SIZE, AMMO_BAR_POS, ammo_max)
	ammo_bar.visible = false
	GUILAYER.add_child(ammo_bar)
	
	# Init material.
	$SprShip.texture = global.create_empty_image(MASK.get_size())
	$SprShip.material.set_shader_param("mask", MASK)
	$SprShip.material.set_shader_param("palette", palettes.get_frame("default", 0))


func _physics_process(delta):
	# Movement.
	var input = get_directional_input()
	var motion = get_motion(input)
	set_fire_sprite()
	move_and_slide(motion)
	
	# Check for collision.
	for i in range(get_slide_count()):
		var collider = get_slide_collision(i).collider
		if collider is CHARACTER:
			collider.collide(self)
			break
	
	# TODO: Move pickup collision detection to here.

func _process(delta):
	# Get new values of this frame.
	mouse_pos = get_viewport().get_mouse_position()
	
	# Calculate rotation.
	rotation = get_rotation()
	
	# Check if we are firing.
	auto_fire += delta
	if Input.is_action_pressed("shoot") and auto_fire >= AUTO_FIRE_INTERVAL:
		fire(n_cannons)
		auto_fire = 0
	
	# Emit propulsion particles.
	$PropulsionParticles.emitting = speed != 0
	var propulsion_dir = - motion_dir
	$PropulsionParticles.global_rotation = propulsion_dir.angle()
	
	########## TEST
	if Input.is_action_just_pressed("ui_down"):
		previous_weapon()
	if Input.is_action_just_pressed("ui_up"):
		next_weapon()
	
	# Update values for next frame.
	mouse_last_pos = mouse_pos

#########################
## Auxiliar functions. ##
#########################

func set_hp_relative(relative_hp):
	hp += relative_hp
	update_bar(hp_bar, hp, hp_max)
	
func set_ammo_relative(relative_ammo):
	ammo[active_weapon] += relative_ammo
	update_bar(ammo_bar, ammo[active_weapon], ammo_max)
	
func set_visibility(value):
	$SprShip.visible = value
	
func get_visibility():
	return $SprShip.visible

func update_bars():
	update_bar(hp_bar, hp, hp_max)
	update_bar(ammo_bar, ammo[active_weapon], ammo_max)

func take_damage(damage):
	.take_damage(damage)
	$HitParticles.emitting = true
	$HitParticles.restart()
	update_bar(hp_bar, hp, hp_max)

func set_fire_sprite():
	if speed == 0:
		pass
		#$SprFire.visible = false
	else:
		#$SprFire.visible = true
		if speed == MOVE_SPEED_MAX * speed_multiplier:
			$SprFire.play("max")
		else:
			$SprFire.play("accelerate")
			$SprFire.frame = float(speed) / (MOVE_SPEED_MAX * speed_multiplier) * $SprFire.frames.get_frame_count("accelerate")
			

func get_directional_input():
	
	var input = Vector2()
	var empty = Vector2()
	
	# Keyboard input.
	if Input.is_action_pressed("keyboard_move_up"):
		input += Vector2.UP
	if Input.is_action_pressed("keyboard_move_down"):
		input += Vector2.DOWN
	if Input.is_action_pressed("keyboard_move_left"):
		input += Vector2.LEFT
	if Input.is_action_pressed("keyboard_move_right"):
		input += Vector2.RIGHT
		
	if input != Vector2():
		global.gamepad = false
		
	var prev_input = input
	# Gamepad input.
	if Input.is_action_pressed("gamepad_move_up"):
		input += Vector2.UP
	if Input.is_action_pressed("gamepad_move_down"):
		input += Vector2.DOWN
	if Input.is_action_pressed("gamepad_move_left"):
		input += Vector2.LEFT
	if Input.is_action_pressed("gamepad_move_right"):
		input += Vector2.RIGHT
		
	if input != prev_input:
		global.gamepad = true
		
	if input == empty:
		# Joystick input.
		input = get_joystick_axis(0, JOY_AXIS_0)
	
	return input

func get_rotation():
	var rot
	var input = get_joystick_axis(0, JOY_AXIS_3)
	
	if input != Vector2():
		global.gamepad = true
		rot = input.angle()
	else:
		rot = rotation
		if mouse_pos != mouse_last_pos:
			global.gamepad = false
	
	if !global.gamepad:
		if position.distance_to(mouse_pos) > 3:
			rot = mouse_pos.angle_to_point(get_global_transform_with_canvas().origin)
		else:
			rot = rotation
	
	return rot

func get_joystick_axis(device, joystick):
	var input = Vector2(Input.get_joy_axis(device, joystick), Input.get_joy_axis(device, joystick + 1))
	if input.length() < JOYSTICK_DEADZONE:
		input = Vector2()
	else:
		global.gamepad = true
	return input

func get_motion(input):
	if input != Vector2():
		# Accelerate.
		speed = clamp(speed + MOVE_SPEED_ACCEL, 0, MOVE_SPEED_MAX)
		motion_dir = input
	else:
		# Deaccelerate.
		speed = clamp(speed - MOVE_SPEED_DEACCEL, 0, MOVE_SPEED_MAX)
	var motion = motion_dir.normalized() * speed * speed_multiplier
	return motion

func fire(ammount):
	var shooted = false
	if ammount % 2 == 1:
		shooted = shoot_projectile(LEMON, "BULLETS_CENTRE", CANNON_CENTRE_POS) or shooted
	if ammount >= 2:
		shooted = shoot_projectile(LEMON, "BULLETS_LEFT", CANNON_LEFT_POS) or shooted
		shooted = shoot_projectile(LEMON, "BULLETS_RIGHT", CANNON_RIGHT_POS) or shooted
		
	if shooted:
		# Play sound only once.
		global.play_audio_random_pitch($SndShoot, Vector2(.98, 1.02))

func shoot_projectile(projectile, group, pos):
	var shooted = get_tree().get_nodes_in_group(group).size() < bullet_max
	# Check if there are too many projectiles.
	if shooted:
		# Fire projectile.
		var inst = projectile.instance()
		inst.init(global_position + pos.rotated(rotation), rotation, group)
		get_parent().add_child(inst)
		
	return shooted
	
func upgrade(type, ammount):
	var value = get(type)
	var value_max = get(type.to_upper() + "_MAX")
	var value_min = get(type.to_upper() + "_MIN")
	if value == value_max:
		# TODO: Add some points or something. Play points sound.
		pass
	else:
		if ammount > 0:
			# TODO: Play upgrade sound.
			$SndUpgrade.play()
		if ammount < 0:
			take_damage(3)
		set(type, min(value_max, max(value + ammount, value_min)))
		if type == "hp_max":
			set_hp_relative(ammount)
			ammo_max = min(value_max, max(value + ammount, value_min))
			set_ammo_relative(value)
			
func set_weapon(weapon) -> bool:
	if unlocked_WEAPONS[weapon]:
		# TODO: Change bullets.
		$SndWeaponSwap.play()
		active_weapon = weapon
		# Set color palette.
		$SprShip.material.set_shader_param("palette", palettes.get_frame("default", weapon))
		# Show ammo.
		ammo_bar.set_palette(weapon)
		ammo_bar.visible = weapon != 0
		# Set ammo value under max.
		ammo[active_weapon] = min(ammo[active_weapon], ammo_max)
		return true
	return false
		

func next_weapon():
	# WARNING: This only works as expected if at least one weapon
	# is unlocked. Mega is unlocked by default and at all time.
	var weapon = max((active_weapon + 1) % WEAPONS.SIZE, 0)
	while !set_weapon(weapon):
		pass

func previous_weapon():
	# WARNING: This only works as expected if at least one weapon
	# is unlocked. Mega is unlocked by default and at all time.
	var weapon = (active_weapon - 1) % WEAPONS.SIZE
	if weapon < 0: 
		weapon = WEAPONS.SIZE - 1
	while !set_weapon(weapon):
		pass

func die():
	# Save the camera position.
	$Camera2D.current = false
	
	# Generate death sequence.
	var inst = death_instance.instance()
	inst.global_position = global_position
	get_parent().add_child(inst)
	
	var new_sprite = $SprShip.duplicate()
	new_sprite.global_rotation = global_rotation
	new_sprite.visible = true
	inst.add_child(new_sprite)
	
	# Tell everyone that I'm dead.
	emit_signal("death")
	# Die already.
	queue_free()