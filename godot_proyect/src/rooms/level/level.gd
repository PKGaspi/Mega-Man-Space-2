extends Node


const SELECT_STAGE_SCREEN = "res://src/rooms/select stage/select_stage.tscn"
const WEAPONS_MENU = preload("res://src/gui/menus/weapon menu/weapon_menu.tscn")

export var level_data: Resource = LevelData.new()

############
## Nodes. ##
############


onready var music_looper = $MusicLooper
onready var game_over_timer = $GameOverTimer
onready var wave_timer = $WaveTimer
onready var snd_wave_help = $SndWaveHelp

onready var game_layer = $GameLayer
onready var megaship = game_layer.get_node("Megaship")

onready var ui = $UILayer
onready var hud = ui.get_node("HUD")
onready var bar_containter = hud.get_node("BarContainer")
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
	ObjectRegistry.connect("boss_registered", self, "_on_boss_registered")


#####################
## Signal methods. ##
#####################


func _on_animation_finished(animation):
	if animation == "ready":
		global.unpause()
		set_entities_visibility(true)


func _on_megaship_death() -> void:
	# Stop any animation or music.
	center_text.set_animation("none") 
	music_looper.stop()
	game_over_timer.start()


func _on_megaship_transitioned(state_path: String) -> void:
	match state_path:
		"TeleportEnd":
			if level_data.current_wave_index == 0:
				# Start the first wave only. This is when the tp animation ends.
				next_wave()


func _on_GameOverTimer_timeout() -> void:
	if global.one_ups == 0:
		print(":(")
		global.game_over() # Resets lifes, e-tanks and points.
		# TODO: Go to game over screen instead of Select Stage screen.
		get_tree().change_scene(SELECT_STAGE_SCREEN)
		
	else:
		global.modify_stat("one_ups", -1)
		reload_level()


func _on_WaveTimer_timeout() -> void:
	snd_wave_help.play()
	# Mega Man 1 platform power may be good for this.
	ObjectRegistry.connect("enemy_registered", self, "_on_enemy_registered")
	for enemy in ObjectRegistry.get_enemies():
		create_enemy_pointer(enemy)


func _on_boss_registered(boss: Boss) -> void:
	# TODO: Set correct palette
	yield(boss, "ready")
	var hp_bar = bar_containter.new_boss_bar(boss.max_hp, boss.hp, Weapon.TYPES.HEAT)
	boss.hp_bar = hp_bar
	boss.connect("tree_exited", hp_bar, "queue_free")


func _on_enemy_registered(enemy: Enemy) -> void:
	if wave_timer.is_stopped():
		# A new enemy has spawned. Point towards it.
		create_enemy_pointer(enemy)
	else:
		# A new enemy has spawned but this is a new wave. Disconnect the help pointers.
		ObjectRegistry.disconnect("enemy_registered", self, "_on_enemy_registered")


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
	game_layer.visible = value
	ObjectRegistry.set_visibility(value)
	if !value:
		# Only hide this text. It will show up itself when needed.
		center_text.visible = value


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
		megaship.create_enemy_wave_pointer(wave, level_data.palette)
		
		wave_timer.start()
		# TODO: Play warning animation.
		center_text.set_animation("warning", 3)
	else:
		wave_timer.stop()
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


func create_enemy_pointer(enemy) -> void:
	megaship.create_enemy_pointer(enemy, level_data.palette)


func reload_level() -> void:
		# Reset level.
		var inst = load(filename).instance()
		inst.level_data = level_data
		get_tree().root.add_child(inst)
		queue_free()


