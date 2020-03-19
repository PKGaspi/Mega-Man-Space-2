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
signal palette_change(new_palette_index)

func _enter_tree() -> void:
	global.MEGASHIP = self # Set global reference.

func _ready():
	
	# Init material.
	connect("palette_change", get_node("SprShip"), "set_palette")
	
	# Connect signals.
	connect("tree_exiting", global, "_on_megaship_tree_exiting")
	global.connect("user_pause", self, "_on_global_user_pause")
	
	set_palette(active_weapon)


func _on_global_user_pause(value):
	if !value:
		speed = 0

#########################
## Auxiliar functions. ##
#########################

func set_visibility(value):
	$SprShip.visible = value


func get_visibility():
	return $SprShip.visible


func take_damage(damage):
	.take_damage(damage)
	$HitParticles.emitting = true
	$HitParticles.restart()


func apply_propulsion_effects(propulsion: Vector2) -> void:
	$SprShip.set_direction(propulsion)
	$PropulsionParticles.emit(propulsion)


func fill(type, ammount):
	if type == "1up":
		global.obtain_1up()
	elif type == "e-tank":
		global.obtain_etank()
	elif type == "heal":
		set_hp_relative(ammount, true)
	elif type == "ammo":
		if active_weapon != Weapon.TYPES.MEGA:
			pass # TODO: set_ammo_relative(ammount, true)


func upgrade(type : String, ammount : float) -> void:
	var old_value = get(type)
	var value_max = get(type.to_upper() + "_MAX")
	var value_min = get(type.to_upper() + "_MIN")
	var new_value
	if old_value and value_max and value_min:
		new_value = clamp(old_value + ammount, value_min, value_max)
	else:
		new_value = 0
	
	if old_value == value_max:
		# TODO: Add some points or something. Play points sound.
		pass
	else:
		if ammount > 0:
			$SndUpgrade.play()
		match type:
			"hp_max":
				# Also change max ammo.
				set_max_hp(new_value)
				# TODO: set_ammo_max(new_value)
			"speed":
				# Changes in the state machine.
				$StateMachine/Move.max_speed += ammount
			"bullet_max":
				# Change bullet max number and shooting cd.
#				if bullet_max != new_value:
#					bullet_max = new_value
#					shooting_cd = shooting_cd - sign(ammount) * .02
				pass
			_:
				# Only change the intended value.
				set(type, new_value)


func set_palette(palette_index : int) -> void:
	# Set color palette.
	var new_palette = palettes.get_frame("default", palette_index)
	# Set propulsion particles new color.
	var image = new_palette.get_data()
	image.lock()
	var new_color_0 = image.get_pixel(2, 0)
	var new_color_1 = image.get_pixel(3, 0)
	$PropulsionParticles.set_color(0, new_color_0)
	$PropulsionParticles.set_color(1, new_color_1)
	image.unlock()
	
	# Emit palette change signal.
	emit_signal("palette_change", palette_index)


func set_weapon(weapon_index : int, play_sound : bool = true) -> bool:
	# TODO: MOVE THIS TO THE CANNON STATE MACHINE
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
		#ammo_bar.visible = weapon_index != 0
		# Save ammo value.
		#weapons_ammo[active_weapon] = ammo
		# TODO: Change bullets.
		
		active_weapon = weapon_index
		#set_ammo(get_ammo())
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
