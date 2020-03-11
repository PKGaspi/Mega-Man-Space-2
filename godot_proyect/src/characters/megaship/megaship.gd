class_name Megaship
extends Character

################
## Resources. ##
################

const LEMON = preload("res://src/bullets/megaship/lemon.tscn")
export(SpriteFrames) var masks = null
export(SpriteFrames) var palettes = null

######################
## Gameplay values. ##
######################
# Moving speed.
const MOVE_SPEED_ACCEL = 30 # In pixels/second^2.
const MOVE_SPEED_DEACCEL = 20 # In pixels/second^2.
const MOVE_SPEED_MAX = 260 # In pixels/second.


const JOYSTICK_DEADZONE = .3
const JOYSTICK_LEFT = JOY_AXIS_0
const JOYSTICK_RIGHT = JOY_AXIS_2

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
const AMMO_MAX_MIN = 18 # Min max ammo.
# Cannons.
const N_CANNONS_MAX = 3 # Max number of active cannons.
# var n_cannons = 1 is in the super class.
const N_CANNONS_MIN = 1 # Min number of active cannons.
# Bullets.
const BULLET_MAX_MAX = 10 # Max max bullets per cannon on screen.
# var bullets_max = 1 is in the super class.
const BULLET_MAX_MIN = 1 # Min max bullets per cannon on screen.

############
# WEAPONS. #
############
var active_weapon = Weapon.TYPES.MEGA # Current active weapon.

# Ammo to consume after every shot on each weapon.
var ammo_per_shot = {
	Weapon.TYPES.MEGA : 0,
	Weapon.TYPES.BUBBLE : -1,
	Weapon.TYPES.AIR : -1,
	Weapon.TYPES.QUICK : -1,
	Weapon.TYPES.HEAT : -1,
	Weapon.TYPES.WOOD : -1,
	Weapon.TYPES.METAL : -1,
	Weapon.TYPES.FLASH : -1,
	Weapon.TYPES.CRASH : -1,
	Weapon.TYPES.ONE : -1,
	Weapon.TYPES.TWO : -1,
	Weapon.TYPES.THREE : -1,
}

# Unlocked WEAPONS.
var unlocked_weapons = global.unlocked_weapons

##############
# HP & ammo. #
##############
# var hp = hp_max # Current HP. This is in character.gd.
var weapons_ammo = { # Current ammo for each weapon.
	Weapon.TYPES.MEGA : ammo_max,
	Weapon.TYPES.BUBBLE : ammo_max,
	Weapon.TYPES.AIR : ammo_max,
	Weapon.TYPES.QUICK : ammo_max,
	Weapon.TYPES.HEAT : ammo_max,
	Weapon.TYPES.WOOD : ammo_max,
	Weapon.TYPES.METAL : ammo_max,
	Weapon.TYPES.FLASH : ammo_max,
	Weapon.TYPES.CRASH : ammo_max,
	Weapon.TYPES.ONE : ammo_max,
	Weapon.TYPES.TWO : ammo_max,
	Weapon.TYPES.THREE : ammo_max,
}

########################
# Mechanics variables. #
########################
var speed = 0 # Speed at this frame.
var motion = Vector2() # Ammount to move.
var motion_dir = Vector2() # Direction of the last movement.
var input_dir = Vector2() # Direction that the user inputs.

##############
## Singals. ##
##############
signal palette_change

func _enter_tree() -> void:
	global.MEGASHIP = self # Set global reference.

func _ready():
	
	# Init material.
	$SprShip.texture = global.create_empty_image(masks.get_frame("iddle", 0).get_size())
	$SprShip.material.set_shader_param("mask", masks.get_frame("iddle", 0))
	$SprShip.material.set_shader_param("palette", palettes.get_frame("default", 0))
	
	# Connect signals.
	connect("tree_exiting", global, "_on_megaship_tree_exiting")
	connect("palette_change", ammo_bar, "set_palette")
	global.connect("user_pause", self, "_on_global_user_pause")



func _on_global_user_pause(value):
	if !value:
		speed = 0

#########################
## Auxiliar functions. ##
#########################

func set_ammo(value, pause = false, weapon = active_weapon):
	.set_ammo(value, pause)
	weapons_ammo[weapon] = ammo

func get_ammo(weapon = active_weapon) -> float:
	return weapons_ammo[clamp(weapon, 1, Weapon.TYPES.SIZE)]

func set_visibility(value):
	$SprShip.visible = value
	
func get_visibility():
	return $SprShip.visible

func take_damage(damage):
	.take_damage(damage)
	$HitParticles.emitting = true
	$HitParticles.restart()

func get_directional_input():
	var input : Vector2 = Vector2.ZERO
	
	match global.input_type:
		global.INPUT_TYPES.GAMEPAD:
			# Gamepad input.
			# Joystick input.
			input = get_joystick_axis(0, JOYSTICK_LEFT)
			continue
		global.INPUT_TYPES.KEY_MOUSE, global.INPUT_TYPES.GAMEPAD:
			# Keyboard input.
			if Input.is_action_pressed("move_up"):
				input += Vector2.UP
			if Input.is_action_pressed("move_down"):
				input += Vector2.DOWN
			if Input.is_action_pressed("move_left"):
				input += Vector2.LEFT
			if Input.is_action_pressed("move_right"):
				input += Vector2.RIGHT
				
		global.INPUT_TYPES.TOUCHSCREEN:
			# Touchscreen input.
			input = get_mobile_joystick_axis(JOYSTICK_LEFT)
		
	return input

func get_rotation():
	var rot : float = rotation
	var input : Vector2
	
	match global.input_type:
		
		global.INPUT_TYPES.KEY_MOUSE:
			# Keyboard input.
			var mouse_pos = get_global_mouse_position()
			if position.distance_to(mouse_pos) > 3:
				input = global_position.direction_to(mouse_pos)
				
		global.INPUT_TYPES.GAMEPAD:
			# Gamepad input.
			input = get_joystick_axis(0, JOYSTICK_RIGHT)
				
		global.INPUT_TYPES.TOUCHSCREEN:
			# Touchscreen input.
			input = get_mobile_joystick_axis(JOYSTICK_RIGHT)
		
	if input != Vector2.ZERO:
		rot = input.angle()
	
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
	return input

func get_mobile_joystick_axis(joystick):
	if joystick == JOYSTICK_LEFT:
		return global.current_touchscreen_layout.get_node("LeftJoystick").output
	elif joystick == JOYSTICK_RIGHT:
		return global.current_touchscreen_layout.get_node("RightJoystick").output

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

func fire(n_cannons : int = self.n_cannons, used_ammo : float = ammo_per_shot[active_weapon]) -> bool:
	# Declared here to change default arguments.
	return .fire(n_cannons, used_ammo)

func emit_propulsion_particles(speed):
	var propulsion_dir = - motion_dir
	
	$PropulsionParticles1.emitting = speed != 0
	$PropulsionParticles1.global_rotation = propulsion_dir.angle()
	$PropulsionParticles1.process_material.initial_velocity = speed / 4
	
	$PropulsionParticles2.emitting = speed != 0
	$PropulsionParticles2.global_rotation = propulsion_dir.angle()
	$PropulsionParticles2.process_material.initial_velocity = speed / 4

func fill(type, ammount):
	if type == "1up":
		$Snd1Up.play()
		global.obtain_1up()
	elif type == "e-tank":
		$Snd1Up.play()
		global.obtain_etank()
	elif type == "heal":
		set_hp_relative(ammount, true)
	elif type == "ammo":
		if active_weapon != Weapon.TYPES.MEGA:
			set_ammo_relative(ammount, true)
	
func upgrade(type : String, ammount : float) -> void:
	var value = get(type)
	var value_max = get(type.to_upper() + "_MAX")
	var value_min = get(type.to_upper() + "_MIN")
	if value == value_max:
		# TODO: Add some points or something. Play points sound.
		pass
	else:
		if ammount > 0:
			$SndUpgrade.play()
		set(type, clamp(value + ammount, value_min, value_max))
		if type == "hp_max":
			# Do extra stuff in this case.
			ammo_max = clamp(value + ammount, value_min, value_max)
			set_hp_relative(0)
			set_ammo_relative(0)
			hp_bar.value = hp
			ammo_bar.value = get_ammo()
			
func set_palette(palette_index : int) -> void:
	# Set color palette.
	var new_palette = palettes.get_frame("default", palette_index)
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
	emit_signal("palette_change", palette_index)

func set_weapon(weapon_index : int, play_sound : bool = true) -> bool:
	if !unlocked_weapons.has(weapon_index):
		weapon_index = Weapon.TYPES.MEGA
	var unlocked = unlocked_weapons[weapon_index]
	if unlocked and weapon_index != active_weapon:
		if play_sound:
			$SndWeaponSwap.play()
		# Set palette.
# warning-ignore:narrowing_conversion
		set_palette(clamp(weapon_index, 0, Weapon.TYPES.ONE))
		# Set ammo_bar visibility.
		ammo_bar.visible = weapon_index != 0
		# Save ammo value.
		weapons_ammo[active_weapon] = ammo
		# TODO: Change bullets.
		
		active_weapon = weapon_index
		set_ammo(get_ammo())
	return unlocked
		

func next_weapon():
	# WARNING: This only works as expected if at least one weapon
	# is unlocked. Mega is unlocked by default and should be at all times.
	var weapon = (active_weapon + 1) % Weapon.TYPES.SIZE
	while !set_weapon(weapon):
		weapon = (weapon + 1) % Weapon.TYPES.SIZE

func previous_weapon():
	# WARNING: This only works as expected if at least one weapon
	# is unlocked. Mega is unlocked by default and should be at all times.
	var weapon = (active_weapon - 1) if active_weapon > 0 else Weapon.TYPES.SIZE - 1
	while !set_weapon(weapon):
		weapon = weapon - 1 if weapon > 0 else Weapon.TYPES.SIZE - 1

func die():
	# Save the camera position.
	$Camera2D.current = false
	
	
	# Generate death scene.
	var inst = death_instance.instance()
	inst.global_position = global_position
	
	# Change particles color to the current palette.
	#var palette = palettes.get_frame("default", active_weapon)
	#var image = palette.get_data()
	#image.lock()
	#var color = image.get_pixel(2, 0)
	#inst.modulate = color
	
	var new_sprite = $SprShip.duplicate()
	new_sprite.global_rotation = global_rotation
	new_sprite.visible = true
	inst.add_child(new_sprite)
	
	# Add death scene to the tree.
	get_parent().add_child(inst)
	# Tell everyone that I'm dead.
	emit_signal("death")
	# Die already.
	queue_free()
