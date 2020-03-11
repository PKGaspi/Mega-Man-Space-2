class_name Character
extends KinematicBody2D


# Bars.
const TILED_PROGRESS = preload("res://src/gui/tiled_progress.tscn")
onready var BAR_CONTAINER = $"/root/Space/GUILayer/Container/BarContainer"
# HP.
export(float, 0, 100, 1) var hp_max = 10 # Max hp.
export(bool) var _hp_bar_show = true
export(bool) var _hp_bar_on_gui = false
export(int) var _hp_bar_palette = 0
export(Vector2) var _hp_bar_cell_size = Vector2(4, 2)
export(Vector2) var _hp_bar_position = Vector2(10, -8)
var hp_bar
var hp : float # Hp.
# Ammo.
export(float, 0, 100, 1) var ammo_max = 28 # Max ammo.
export(bool) var _ammo_bar_show : bool = false
export(bool) var _ammo_bar_on_gui : bool = false
export(int) var _ammo_bar_palette : int = 0
export(Vector2) var _ammo_bar_cell_size : Vector2 = Vector2(4, 2)
export(Vector2) var _ammo_bar_position : Vector2 = Vector2(15, -8)
var ammo_bar
var ammo : float # Ammo.

export(NodePath) var snd_hit = "SndHit"
export(NodePath) var snd_shoot = "SndShoot"
export(PackedScene) var death_instance = null

# Flickering and invencibility.
export(float) var invencibility_time : float = .5 # Seconds the character is invencible after hit.
export(float) var life_time : float = 10 # Seconds until the character disapears.
export(float) var life_flicker_time : float = 8 # Start flickering when the character has this many seconds of life.
export(bool) var flicker_on_hit : bool = true
export(bool) var flicker_before_timeout : bool = false
export(bool) var dissapear_on_timeout : bool = false
var flickering_interval : float = .05 # Seconds between each visibility toggle when flickering.
var flickering_timer : float = 0 # Seconds until a toggle on visibility is made.
var invencible : bool = false
var flickering : bool = false
var disappearing : bool = false

# Bullets.
# Auto fire cooldown.
export var shooting_cd: float = .05 # Min seconds between shootings.
var shooting_remaining_cd: float = 0 # Seconds to wait until next shooting is posible.
export(PackedScene) var bullet = null
export(Array, Array, Vector2) var cannon_pos = [[Vector2()]]
export(int) var bullet_max : int = 3
export(int) var n_cannons : int = 1

export(Dictionary) var DAMAGE_MULTIPLIERS = { 
	Weapon.TYPES.MEGA : 1,
	Weapon.TYPES.BUBBLE : 1,
	Weapon.TYPES.AIR : 1,
	Weapon.TYPES.QUICK : 1,
	Weapon.TYPES.HEAT : 1,
	Weapon.TYPES.WOOD : 1,
	Weapon.TYPES.METAL : 1,
	Weapon.TYPES.FLASH : 1,
	Weapon.TYPES.CRASH : 1,
}

# Motion.
var acceleration : float = 1
var momentum : Vector2 = Vector2.ZERO
var friction : float = .2

# Signals.
signal death



func _ready() -> void:
	hp = hp_max
	ammo = ammo_max
	# Init bars.
	hp_bar = create_progress_bar(_hp_bar_cell_size, _hp_bar_position, hp_max, _hp_bar_show, _hp_bar_on_gui, _hp_bar_palette, "HpBar")
	ammo_bar = create_progress_bar(_ammo_bar_cell_size, _ammo_bar_position, ammo_max, _ammo_bar_show, _ammo_bar_on_gui, _ammo_bar_palette, "AmmoBar")
	
	# Init timers.
	if flicker_before_timeout:
		$LifeFlickeringTimer.start(life_flicker_time)
	if dissapear_on_timeout:
		$LifeTimer.start(life_time)


func _physics_process(delta: float) -> void:
	
	# Reduce shooting cd.
	shooting_remaining_cd = max(0, shooting_remaining_cd - delta)
	
	# Apply and update momentum.
	move_and_slide(momentum)
	momentum *= friction


func _on_flickering_timer_timeout():
	if flickering:
		flicker()
	else:
		$FlickeringTimer.stop()
		set_visibility(true)


func _on_invencibility_timer_timeout():
	flickering = disappearing
	set_invencible(false)


func _on_life_timer_timeout():
	disappear()


func _on_life_flickering_timer_timeout():
	disappearing = true
	flicker()


#########################
## Auxiliar functions. ##
#########################


func create_progress_bar(cell_size : Vector2, pos : Vector2, max_value : float, show : bool = true, on_gui : bool = false, palette : int = 0, name : String = ""):
	var bar = TILED_PROGRESS.instance()
	bar.cell_size = cell_size
	bar.rect_position = pos
	bar.max_value = max_value
	bar.visible = show
	bar.palette = palette
	
	if on_gui:
		if name != "":
			bar.name = self.name + name
		BAR_CONTAINER.add_child(bar)
	else:
		if name != "":
			bar.name = name
		add_child(bar)
	
	return bar


func set_visibility(value):
	visible = value


func get_visibility():
	return visible


func toggle_visibility():
	set_visibility(!get_visibility())


func set_hp(value, pause = false):
	hp = clamp(value, 0, hp_max)
	hp_bar.set_value(hp, pause)


func set_hp_relative(relative_value, pause = false):
	set_hp(hp + relative_value, pause)


func get_ammo():
	return ammo


func set_ammo(value, pause = false):
	ammo = clamp(value, 0, ammo_max)
	ammo_bar.set_value(value, pause)


func set_ammo_relative(relative_value, pause = false):
	set_ammo(ammo + relative_value, pause)


func flicker(interval = flickering_interval):
	$FlickeringTimer.start(interval)
	flickering = true
	toggle_visibility()


func push(motion):
	momentum += motion


func hit(damage, weapon = Weapon.TYPES.MEGA):
	if !invencible:
		# TODO: Calculate damage with enemy weakness and type.
		take_damage(damage)


func take_damage(damage):
	# Play hit sound.
	global.play_audio_random_pitch(get_node(snd_hit), Vector2(.90, 1.10))
	set_hp_relative(-damage)
	set_invencible(true)
	check_death()


func set_invencible(value : bool) -> void:
	invencible = value
	if value:
		$InvencibilityTimer.start(invencibility_time)
		flicker()


func check_death():
	if hp <= 0:
		# Oh wow I'm dead.
		die()


func die():
	# Destroy myself by default.
	emit_signal("death")
	if death_instance != null:
		# Creat death scene.
		var inst = death_instance.instance()
		inst.global_position = global_position
		get_parent().add_child(inst)
	queue_free()


func disappear():
	# Destroy myself by default.
	queue_free()


func fire(n_cannons : int = self.n_cannons, used_ammo : float = -.2) -> bool:
	# Called when there is an attempt to shoot. This method checks that a
	# shoot is viable and if so creates the projectiles via shoot_projectile().
	var shooted = false
	var able_to_shoot = ammo > 0 and shooting_remaining_cd == 0 # Check if there is enough ammo and the cd is 0.
	if able_to_shoot:
		var cannons = cannon_pos[n_cannons - 1]
		for cannon in cannons:
			shooted = shoot_projectile(cannon) or shooted # If any cannon shooted, return true and act as so.
		if shooted:
			shooting_remaining_cd = shooting_cd # Put shooting on cd.
			set_ammo_relative(used_ammo) # Consume ammo.
			global.play_audio_random_pitch(get_node(snd_shoot), Vector2(.98, 1.02)) # Play sound.
	return shooted


func shoot_projectile(pos: Vector2, projectile: Bullet = bullet) -> bool:
	var group = str(pos) + str(self)
	var shooted = get_tree().get_nodes_in_group(group).size() < bullet_max
	# Check if there are too many projectiles.
	if shooted:
		# Fire projectile.
		var inst = projectile.instance()
		inst.init(global_position + pos.rotated(rotation), rotation, group)
		get_parent().add_child(inst)
	return shooted


func is_in_range(object : Node2D, radious):
	return object != null and (global_position.distance_to(object.global_position) <= radious or radious < 0)
