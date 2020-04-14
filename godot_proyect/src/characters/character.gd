class_name Character
extends KinematicBody2D

const FLICKER_INTERVAL = 4.0 / 60.0

# Stats.
export var stats: Resource
var hp: float setget set_hp
var max_hp: float setget set_max_hp
# Seconds the character is invencible after getting hit.
var invencibility_time: float setget set_invencibility_time 
# A dictionary with multipliers of what makes more damage or less to this character.
var weaknesses: Dictionary
var collision_damage: float

# HP bar.
export var _hp_bar_path: NodePath
onready var hp_bar: TiledProgress

# Cannons.
export var _cannons_path: NodePath
var cannons

# Death
export(PackedScene) var death_instance = null

# State variables.
var invencible: bool = false setget set_invencible

# Nodes.
var flickering_timer := Timer.new()
var invencibility_timer := Timer.new()
onready var snd_hit := $SndHit
onready var snd_upgrade := $SndUpgrade

# Signals.
signal shooted()
signal hitted(total_damage, direction)
signal death()



func _ready() -> void:
	# Set nodes.
	if has_node(_cannons_path):
		cannons = get_node(_cannons_path)
	if has_node(_hp_bar_path):
		hp_bar = get_node(_hp_bar_path)
	
	# Set timers.
	flickering_timer.name = "FlickeringTimer"
	invencibility_timer.name = "InvencibilityTimer"
	
	flickering_timer.connect("timeout", self, "_on_flickering_timer_timeout")
	invencibility_timer.connect("timeout", self, "_on_invencibility_timer_timeout")
	
	flickering_timer.wait_time = FLICKER_INTERVAL
	invencibility_timer.one_shot = true
	
	add_child(flickering_timer)
	add_child(invencibility_timer)
	
	# Set initial stats.
	assert(stats != null)
	stats.initialize()
	set_max_hp(stats.get_stat("max_hp"))
	set_hp(max_hp)
	set_invencibility_time(stats.get_stat("invencibility_time"))
	weaknesses = stats.get_stat("weaknesses")
	collision_damage = stats.get_stat("collision_damage")
	
	# Signals.
	stats.connect("stat_changed", self, "_on_stat_changed")
	


func _on_flickering_timer_timeout() -> void:
	toggle_visibility()


func _on_invencibility_timer_timeout() -> void:
	set_invencible(false)


func _on_stat_changed(stat_name: String, new_value: float) -> void:
	match stat_name:
		"max_hp": set_max_hp(new_value)
		"invencibility_time": set_invencibility_time(new_value)


##########################
## Setters and getters. ##
##########################


func set_visibility(value) -> void:
	visible = value


func get_visibility() -> bool:
	return visible


func toggle_visibility() -> void:
	set_visibility(!get_visibility())


func set_hp(value: float, pause := false) -> void:
	hp = clamp(value, 0, max_hp)
	if hp_bar != null:
		hp_bar.set_value(hp, pause)
	check_death()


func set_hp_relative(relative_value: float, pause := false) -> void:
	set_hp(hp + relative_value, pause)


func set_max_hp(value: float) -> void:
	max_hp = value
	if hp_bar != null:
		hp_bar.max_value = value


func set_invencibility_time(value: float) -> void:
	invencibility_time = value
	invencibility_timer.wait_time = invencibility_time


func set_invencible(value: bool) -> void:
	invencible = value
	if invencible:
		toggle_visibility()
		invencibility_timer.start()
		flickering_timer.start()
	else:
		set_visibility(true)
		invencibility_timer.stop()
		flickering_timer.stop()


####################
## API functions. ##
####################


func shoot(power: int = 0) -> bool:
	if is_instance_valid(cannons) and cannons.fire(power):
		emit_signal("shooted")
		return true
	
	return false


func collide_character(character) -> void:
	# self collided with character. character gets hit by self.
	var dir = global_position.direction_to(character.global_position)
	character.hit(collision_damage, dir)


func hit_bullet(bullet) -> void:
	# bullet collided with self. self gets hit by the bullet.
	hit(bullet.damage, bullet.dir, bullet.weapon)


func hit(damage: float, dir: Vector2, weapon: int = Weapon.TYPES.MEGA) -> void:
	if not invencible:
		snd_hit.play()
		set_invencible(true)
		# TODO: Calculate damage with enemy weakness and type.
		var total_damage = damage
		set_hp_relative(-total_damage)
		emit_hit_particles()
		emit_signal("hitted", total_damage, dir)


func emit_hit_particles() -> void:
	pass

func check_death() -> void:
	# Overwrite to add more death conditions.
	if hp <= 0:
		# Oh wow I'm dead.
		die()


func die() -> void:
	emit_signal("death")
	if death_instance != null:
		# Create death scene.
		var inst = death_instance.instance()
		inst.global_position = global_position
		get_parent().add_child(inst)
	# Destroy myself.
	queue_free()


func disappear() -> void:
	# Just destroy myself by default.
	queue_free()


func modify_stat(stat_name: String, stat_owner: int, ammount: float) -> void:
	match stat_owner:
		StatsPickup.OWNERS.GLOBAL:
			global.modify_stat(stat_name, ammount)
		StatsPickup.OWNERS.CANNON:
			if cannons != null:
				if stat_name == "ammo": cannons.set_ammo_relative(ammount, true)
				else: 
					if ammount > 0:
						snd_upgrade.play()
					cannons.stats.modify_stat(stat_name, ammount)
		StatsPickup.OWNERS.CHARACTER:
			if stat_name == "hp": set_hp_relative(ammount, true)
			else: 
				if ammount > 0:
					snd_upgrade.play()
				stats.modify_stat(stat_name, ammount)


#########################
## Auxiliar functions. ##
#########################


func is_in_range(object: Node2D, radious: float) -> bool:
	return object != null and (global_position.distance_to(object.global_position) <= radious or radious < 0)
