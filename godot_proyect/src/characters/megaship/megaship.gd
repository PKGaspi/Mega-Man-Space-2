extends "res://src/characters/character.gd"

################
## Resources. ##
################

const CHARACTER = preload("res://src/characters/character.gd")

const LEMON = preload("res://src/characters/megaship/bullets/lemon.tscn")
export(SpriteFrames) var masks = null
export(SpriteFrames) var palettes = null

onready var GUILAYER = $"/root/Space/GUILayer"
# Bars.
const PROGRESS_BAR = preload("res://src/gui/progress_bar.tscn")
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

############
# WEAPONS. #
############
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
var motion = Vector2() # Ammount to move.
var motion_dir = Vector2() # Direction of the last movement.
var input_dir = Vector2() # Direction that the user inputs.

##############
## Singals. ##
##############
signal palette_change

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
	connect("palette_change", ammo_bar, "_on_megaship_palette_change")
	GUILAYER.add_child(ammo_bar)
	
	# Init material.
	$SprShip.texture = global.create_empty_image(masks.get_frame("iddle", 0).get_size())
	$SprShip.material.set_shader_param("mask", masks.get_frame("iddle", 0))
	$SprShip.material.set_shader_param("palette", palettes.get_frame("default", 0))
	
	


func _physics_process(delta):
	# Movement.
	input_dir = get_directional_input()
	motion = get_motion(input_dir)
	move_and_slide(motion)
	# Check for collision.
	for i in range(get_slide_count()):
		var collider = get_slide_collision(i).collider
		if collider is CHARACTER:
			collider.collide(self)
			break
	

func _process(delta):
	# Get new values of this frame.
	mouse_pos = get_viewport().get_mouse_position()
	
	# Calculate rotation and sprite.
	rotation = get_rotation()
	
	# Check if we are firing.
	auto_fire += delta
	if Input.is_action_pressed("shoot") and auto_fire >= AUTO_FIRE_INTERVAL:
		fire(n_cannons)
		auto_fire = 0
	
	# Emit propulsion particles.
	propulsion_particles(speed)
	
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

func set_hp_relative(relative_hp, pause = false):
	hp += relative_hp
	update_bar(hp_bar, hp, hp_max, pause)
	
func set_ammo_relative(relative_ammo, pause = false):
	if active_weapon != WEAPONS.MEGA:
		ammo[active_weapon] += relative_ammo
		update_bar(ammo_bar, ammo[active_weapon], ammo_max, pause)
	
func set_visibility(value):
	$SprShip.visible = value
	
func get_visibility():
	return $SprShip.visible

func take_damage(damage):
	.take_damage(damage)
	$HitParticles.emitting = true
	$HitParticles.restart()
	update_bar(hp_bar, hp, hp_max)

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
	
	# Calculate rotation.
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
	
	# Set rotation sprite.
	if input_dir == Vector2():
		$SprShip.material.set_shader_param("mask", masks.get_frame("iddle", 0))
	else:
		var sprite_angle = int(round(rad2deg(input_dir.angle() - rot)))
		# Work only with positive angles.
		if sprite_angle < 0:
			sprite_angle += 360
		# Make the angle change in an interval of 45 / 2 degs.
		if sprite_angle % 45 >= 45 / 2:
			sprite_angle += 45 - sprite_angle % 45
		else:
			sprite_angle -= sprite_angle % 45
		sprite_angle %= 360
		# Set the corresponding mask
		$SprShip.material.set_shader_param("mask", masks.get_frame(str(sprite_angle), 0))
		
	
	return rot

func get_joystick_axis(device, joystick):
	var input = Vector2(Input.get_joy_axis(device, joystick), Input.get_joy_axis(device, joystick + 1))
	if input.length() < JOYSTICK_DEADZONE:
		input = Vector2()
	else:
		global.gamepad = true
	return input

func get_motion(dir):
	if dir != Vector2():
		# Accelerate.
		speed = clamp(speed + MOVE_SPEED_ACCEL, 0, MOVE_SPEED_MAX)
		motion_dir = dir
	else:
		# Deaccelerate.
		speed = clamp(speed - MOVE_SPEED_DEACCEL, 0, MOVE_SPEED_MAX)
	var motion = min(1, motion_dir.length()) * motion_dir.normalized() * speed * speed_multiplier
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

func propulsion_particles(speed):
	var propulsion_dir = - motion_dir
	
	$PropulsionParticles1.emitting = speed != 0
	$PropulsionParticles1.global_rotation = propulsion_dir.angle()
	$PropulsionParticles1.process_material.initial_velocity = speed / 4
	
	$PropulsionParticles2.emitting = speed != 0
	$PropulsionParticles2.global_rotation = propulsion_dir.angle()
	$PropulsionParticles2.process_material.initial_velocity = speed / 4

func fill(type, ammount):
	if type == "1up":
		global.obtain_1up()
	elif type == "e-tank":
		global.obtain_etank()
	elif type == "heal":
		set_hp_relative(ammount, true)
	elif type == "ammo":
		set_ammo_relative(ammount, true)
	
func upgrade(type, ammount):
	var value = get(type)
	var value_max = get(type.to_upper() + "_MAX")
	var value_min = get(type.to_upper() + "_MIN")
	if value == value_max:
		# TODO: Add some points or something. Play points sound.
		pass
	else:
		if ammount > 0:
			$SndUpgrade.play()
		set(type, min(value_max, max(value + ammount, value_min)))
		if type == "hp_max":
			set_hp_relative(ammount)
			ammo_max = min(value_max, max(value + ammount, value_min))
			set_ammo_relative(value)
			
func set_palette(weapon_index : int) -> void:
	# Set color palette.
	var new_palette = palettes.get_frame("default", weapon_index)
	$SprShip.material.set_shader_param("palette", new_palette)
	# Set propulsion particles new color.
	var image = new_palette.get_data()
	image.lock()
	var new_color_1 = image.get_pixel(2, 0)
	var new_color_2 = image.get_pixel(3, 0)
	$PropulsionParticles1.process_material.color = new_color_1
	$PropulsionParticles2.process_material.color = new_color_2
	image.unlock()
	
	# Emit palette change signal.
	emit_signal("palette_change", weapon_index)

func set_weapon(weapon_index : int) -> bool:
	if unlocked_WEAPONS[weapon_index]:
		$SndWeaponSwap.play()
		active_weapon = weapon_index
		set_palette(weapon_index)
		# Show ammo.
		ammo_bar.visible = weapon_index != 0
		# Set ammo value under max.
		ammo[active_weapon] = min(ammo[active_weapon], ammo_max)
		# TODO: Change bullets.
		
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