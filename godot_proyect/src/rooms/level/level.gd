extends Node


const SELECT_STAGE_SCREEN = "res://src/rooms/select stage/select_stage.tscn"
const WEAPONS_MENU = preload("res://src/gui/menus/weapon menu/weapon_menu.tscn")

export var level_data: Resource = LevelData.new()

############
## Nodes. ##
############


onready var music_looper = $MusicLooper
onready var game_over_timer = $GameOverTimer

onready var game_layer = $GameLayer
onready var megaship = game_layer.get_node("Megaship")

onready var ui = $UILayer
onready var hud = ui.get_node("HUD")
onready var center_text = ui.get_node("CenterContainer/CenterText")


############
## Songs. ##
############



func _ready() -> void:
	# Set as current scene.
	get_tree().current_scene = self
	ObjectRegistry.reset()
	
	# Touchscreen controls.
	global.create_touchscreen_layout(hud)
	
	# Resources init.
	level_data.initialize()
	set_music(level_data.music_intro, level_data.music_loop)
	start_ready_animation()
	
	# Setup signals.
	global.connect("user_paused", self, "_on_global_user_pause")
	megaship.connect("death", self, "_on_megaship_death")
	center_text.connect("animation_finished", self, "_on_animation_finished")


#####################
## Signal methods. ##
#####################


func _on_animation_finished(animation):
	if animation == "ready":
		global.unpause()
		set_entities_visibility(true)
		next_wave()


func _on_megaship_death() -> void:
	# Stop any animation or music.
	center_text.set_animation("none") 
	music_looper.stop()
	game_over_timer.start()


func _on_game_over_timer_timeout() -> void:
	if global.one_ups == 0:
		print(":(")
		global.game_over() # Resets lifes, e-tanks and points.
		# TODO: Go to game over screen instead of Select Stage screen.
		get_tree().change_scene(SELECT_STAGE_SCREEN)
		
	else:
		global.modify_stat("one_ups", -1)
		reload_level()


func _on_global_user_pause(value) -> void:
	set_entities_visibility(!value)
	if value: # Game is paused.
		create_weapons_menu()


##########
## API. ##
##########


func set_music(music_intro: AudioStream, music_loop: AudioStream) -> void:
	music_looper.intro = music_intro
	music_looper.loop = music_loop
	music_looper.play()


func set_entities_visibility(value: bool) -> void:
	hud.visible = value
	center_text.visible = value
	game_layer.visible = value
	ObjectRegistry.set_visibility(value)


func start_ready_animation() -> void:
	center_text.set_animation("ready", 3)
	set_entities_visibility(false)
	center_text.visible = true
	global.pause()


func next_wave() -> void:
	var wave_data = level_data.next_wave()
	if wave_data != null:
		# Spawn wave.
		var wave := EnemyWave.new()
		wave.wave_data = wave_data
		wave.name = "EnemyWave"
		wave.connect("completed", self, "next_wave")
		game_layer.add_child(wave)
		# Create the enemy wave pointer so the player can find it.
		var pointer = megaship.create_enemy_wave_pointer(wave_data.center)
		pointer.palette = level_data.palette
		wave.connect("completed", pointer, "queue_free")
		# TODO: Play warning animation.
	else:
		print("muy bien!!")
		# TODO: Start victory animation


func create_weapons_menu() -> void:
	var inst = WEAPONS_MENU.instance()
	inst.set_palette(level_data.palette)
	var weapon_index = megaship.get_weapon()
	var unlocked_weapons = global.unlocked_weapons
	var unlocked_entries = {}
	# Create dictionary with the unlocked entries. Key is a vector2 with
	# page-entry and value is a boolean true if unlocked.
	for i in range(Weapon.TYPES.size()):
		unlocked_entries[Vector2(floor(i / 6), 1 + i % 6)] = unlocked_weapons[i]
	inst.unlocked_entries = unlocked_entries
	ui.add_child(inst)
	yield(inst, "opened")
	# Set active entry of the current weapon.
	# warning-ignore:unused_variable
	for i in range(floor(weapon_index / 6)):
		inst.next_page()
	inst.set_entry((weapon_index % 6) + 1)


func reload_level() -> void:
		# Reset level.
		var inst = load(filename).instance()
		inst.level_data = level_data
		get_tree().root.add_child(inst)
		queue_free()
