class_name Megaship
extends Character

################
## Resources. ##
################

var ENEMY_WAVE_POINTER = preload("res://src/characters/megaship/pointers/enemy_wave_pointer.tscn")
var ENEMY_POINTER = preload("res://src/characters/megaship/pointers/enemy_pointer.tscn")

var palettes = preload("res://resources/characters/megaship/megaship_palettes.tres")

onready var hit_particles := $HitParticles
onready var propulsion_particles := $PropulsionParticles
onready var state_machine := $StateMachine

onready var spr_ship := $SprShip
onready var snd_teleport := $SndTeleport

##############
## Singals. ##
##############

signal palette_changed(new_palette_index)


##################
### Functions. ###
##################


func _enter_tree() -> void:
	global.MEGASHIP = self # Set global reference.


func _ready():
	# Connect signals.
	connect("tree_exiting", global, "_on_megaship_tree_exiting")
	global.connect("user_paused", self, "_on_user_pause")


func _on_user_pause(value):
	if value:
		state_machine.transition_to("TeleportEnd")


##################
## MEGASHIP API ##
##################


func set_visibility(value):
	spr_ship.visible = value


func get_visibility():
	return spr_ship.visible


func apply_propulsion_effects(propulsion: Vector2) -> void:
	spr_ship.set_direction(propulsion)
	propulsion_particles.emit(propulsion)


func emit_hit_particles() -> void:
	hit_particles.emitting = true
	hit_particles.restart()


func create_enemy_wave_pointer(wave: EnemyWave, palette: int) -> void:
	var wave_data = wave.wave_data
	var pointer: PointingSprite = ENEMY_WAVE_POINTER.instance()
	pointer.pointing_to = wave_data.center
	pointer.palette = palette
	wave.connect("completed", pointer, "queue_free")
	add_child(pointer)
	pointer.owner = self


func create_enemy_pointer(enemy: Enemy, palette: int) -> void:
	var pointer: PointingSprite = ENEMY_POINTER.instance()
	pointer.to_owner = enemy
	pointer.palette = palette
	enemy.connect("tree_exited", pointer, "queue_free")
	add_child(pointer)
	pointer.owner = self


func set_palette(palette_index : int) -> void:
	# Set color palette.
	var new_palette = palettes.get_frame("default", palette_index)
	# Set propulsion particles new color.
	var image = new_palette.get_data()
	image.lock()
	var new_color_0 = image.get_pixel(2, 0)
	var new_color_1 = image.get_pixel(3, 0)
	propulsion_particles.set_color(0, new_color_0)
	propulsion_particles.set_color(1, new_color_1)
	image.unlock()
	
	# Emit palette change signal.
	emit_signal("palette_changed", palette_index)


func die():
	# Generate death scene.
	var inst = death_instance.instance()
	inst.global_position = global_position
	
	# Change particles color to the current palette.
	#var palette = palettes.get_frame("default", active_weapon)
	#var image = palette.get_data()
	#image.lock()
	#var color = image.get_pixel(2, 0)
	#inst.modulate = color
	
	var new_sprite = spr_ship.duplicate()
	new_sprite.global_rotation = global_rotation
	new_sprite.visible = true
	inst.add_child(new_sprite)
	
	# Add death scene to the tree.
	get_parent().add_child(inst)
	# Tell everyone that I'm dead.
	emit_signal("death")
	# Die already.
	queue_free()





### LEGACY FUNCTIONS FOR COMPATIBILITY ###

func get_ammo() -> float:
	return cannons.ammo


func get_weapon() -> int:
	return cannons.weapon


func set_weapon(weapon_index : int, play_sound : bool = true) -> bool:
	return cannons.set_weapon(weapon_index, play_sound)


func next_weapon():
	# WARNING: This only works as expected if at least one weapon
	# is unlocked. Mega is unlocked by default and should be at all times.
	cannons.next_weapon()


func previous_weapon():
	# WARNING: This only works as expected if at least one weapon
	# is unlocked. Mega is unlocked by default and should be at all times.
	cannons.previous_weapon()
