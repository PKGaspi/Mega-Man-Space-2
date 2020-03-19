class_name Character
extends KinematicBody2D

# Stats.
export var stats: Resource
# Bars.
export var _hp_bar_path: NodePath
onready var hp_bar: TiledProgress = get_node(_hp_bar_path)
var hp
var max_hp

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
var friction : float = .2

# Signals.
signal death



func _ready() -> void:
	assert(stats != null)
	stats.initialize()
	max_hp = stats.get_stat("max_hp")
	hp = max_hp
	# Init timers.
	if flicker_before_timeout:
		$LifeFlickeringTimer.start(life_flicker_time)
	if dissapear_on_timeout:
		$LifeTimer.start(life_time)


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


func set_visibility(value):
	visible = value


func get_visibility():
	return visible


func toggle_visibility():
	set_visibility(!get_visibility())


func set_hp(value, pause = false):
	hp = clamp(value, 0, max_hp)
	if hp_bar != null:
		hp_bar.set_value(hp, pause)


func set_hp_relative(relative_value, pause = false):
	set_hp(hp + relative_value, pause)


func set_max_hp(value):
	max_hp = value
	if hp_bar != null:
		hp_bar.max_value = value


func flicker(interval = flickering_interval):
	$FlickeringTimer.start(interval)
	flickering = true
	toggle_visibility()


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


func is_in_range(object : Node2D, radious):
	return object != null and (global_position.distance_to(object.global_position) <= radious or radious < 0)
