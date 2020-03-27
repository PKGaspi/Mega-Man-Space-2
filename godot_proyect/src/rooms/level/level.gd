extends Node


const WEAPONS_MENU = preload("res://src/gui/menus/weapon menu/weapon_menu.tscn")


############
## Nodes. ##
############


onready var music_looper = $MusicLooper
onready var game_over_timer = $GameOverTimer

onready var game_layer = $GameLayer
onready var megaship = game_layer.get_node("Megaship")
onready var enemy_generator = game_layer.get_node("EnemyGenerator")

onready var ui = $UILayer
onready var hud = ui.get_node("HUD")
onready var center_text = hud.get_node("CenterContainer/CenterText")


############
## Songs. ##
############


var music_intros = {
	Weapon.TYPES.MEGA : preload("res://assets/music/stage_crashman_intro.wav"),
	Weapon.TYPES.AIR : null,
	Weapon.TYPES.BUBBLE : preload("res://assets/music/stage_bubbleman_intro.wav"),
	Weapon.TYPES.CRASH : preload("res://assets/music/stage_crashman_intro.wav"),
	Weapon.TYPES.FLASH : preload("res://assets/music/stage_flashman_intro.wav"),
	Weapon.TYPES.HEAT : null,
	Weapon.TYPES.METAL : null,
	Weapon.TYPES.QUICK : null,
	Weapon.TYPES.WOOD : preload("res://assets/music/stage_woodman_intro.wav"),
}

var music_loops = {
	Weapon.TYPES.MEGA : preload("res://assets/music/stage_crashman_loop.ogg"),
	Weapon.TYPES.AIR : preload("res://assets/music/stage_airman_loop.ogg"),
	Weapon.TYPES.BUBBLE : preload("res://assets/music/stage_bubbleman_loop.ogg"),
	Weapon.TYPES.CRASH : preload("res://assets/music/stage_crashman_loop.ogg"),
	Weapon.TYPES.FLASH : preload("res://assets/music/stage_flashman_loop.ogg"),
	Weapon.TYPES.HEAT : preload("res://assets/music/stage_heatman_loop.ogg"),
	Weapon.TYPES.METAL : preload("res://assets/music/stage_metalman_loop.ogg"),
	Weapon.TYPES.QUICK : preload("res://assets/music/stage_quickman_loop.ogg"),
	Weapon.TYPES.WOOD : preload("res://assets/music/stage_woodman_loop.ogg"),
}



var lvl_id = 0 # This is set when selecting the level.



func _ready() -> void:
	get_tree().current_scene = self
	
	# Setup signals.
	global.connect("user_paused", self, "_on_global_user_pause")
	megaship.connect("death", self, "_on_megaship_death")
	center_text.connect("animation_finished", self, "_on_animation_finished")
	
	# Touchscreen controls.
	global.create_touchscreen_layout(hud)
	
	# Music and ready animation.
	set_music(lvl_id)
	start_ready_animation()


func _on_animation_finished(animation):
	if animation == "ready":
		global.unpause()
		megaship.visible = true
		enemy_generator.new_random_horde()


func _on_megaship_death() -> void:
	death()


func _on_game_over_timer_timeout() -> void:
	global.lifes -= 1
	if global.lifes < 0:
		print(":(")
		global.game_over() # Resets lifes, e-tanks and points.
		# TODO: Go to game over screen.
	get_tree().reload_current_scene()
	# TODO: Fix lvl_id resetting to 0.


func _on_global_user_pause(value) -> void:
	hud.visible = !value
	game_layer.visible = !value
	if value: # Game is paused.
		create_weapons_menu()


func set_music(music_index: int) -> void:
	if music_intros.has(music_index) and music_loops.has(music_index):
		var intro = music_intros[music_index]
		var loop = music_loops[music_index]
		music_looper.intro = intro
		music_looper.loop = loop
		music_looper.play()


func start_ready_animation():
	megaship.visible = false
	center_text.set_animation("ready", 3)
	global.pause()


func create_weapons_menu() -> void:
	var inst = WEAPONS_MENU.instance()
	inst.set_palette(lvl_id)
	var weapon_index = megaship.get_weapon()
	var unlocked_weapons = global.unlocked_weapons
	var unlocked_entries = {}
	for i in range(12):
		# Create dictionary with the unlocked entries. Key is a vector2 with
		# page-entry and value is a boolean true if unlocked.
		unlocked_entries[Vector2(floor(i / 6), 1 + i % 6)] = unlocked_weapons[i]
	inst.unlocked_entries = unlocked_entries
	ui.add_child(inst)
	yield(inst, "opened")
	# Set active entry of the current weapon.
# warning-ignore:unused_variable
	for i in range(floor(weapon_index / 6)):
		inst.next_page()
	inst.set_entry((weapon_index % 6) + 1)


func death() -> void:
	center_text.set_animation("none") # Stop any animation.
	music_looper.stop()
	game_over_timer.start()
