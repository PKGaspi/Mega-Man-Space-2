extends Node


const GAME_OVER_SCREEN := preload("res://src/rooms/game over/game_over_screen.tscn")
const WEAPON_GET_SCREEN := "res://src/rooms/weapon get/weapon_get_screen.tscn"
const WEAPONS_MENU := preload("res://src/gui/menus/weapon menu/weapon_menu.tscn")

export var level_data: Resource = LevelData.new()
var current_wave: EnemyWave

############
## Nodes. ##
############


onready var level_music := $MscLevel
onready var boss_music := $MscBoss
onready var victory_music := $MscVictory
onready var snd_wave_help := $SndWaveHelp
onready var snd_victory_teleport := $SndVictoryTeleport

onready var game_over_timer := $GameOverTimer
onready var victory_timer := $VictoryTimer
onready var wave_timer := $WaveTimer

onready var game_layer := $GameLayer
onready var megaship := game_layer.get_node("Megaship")
onready var camera := game_layer.get_node("Camera")

onready var ui := $UILayer
onready var hud := ui.get_node("HUD")
onready var bar_containter := hud.get_node("BarContainer")
onready var center_text := ui.get_node("CenterContainer/CenterText")


############
## Songs. ##
############



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# Set as current scene.
	get_tree().current_scene = self
	ObjectRegistry.reset()
	
	# Touchscreen controls.
	global.create_touchscreen_layout(hud)
	
	# Resources init.
	set_music(level_data.music_intro, level_data.music_loop)
	start_ready_animation()
	
	# Setup signals.
	global.connect("user_paused", self, "_on_global_user_pause")
	megaship.connect("death", self, "_on_megaship_death")
	center_text.connect("animation_finished", self, "_on_animation_finished")
	ObjectRegistry.connect("boss_registered", self, "_on_boss_registered")
	connect("tree_exiting", self, "_on_tree_exiting")


#####################
## Signal methods. ##
#####################


func _on_animation_finished(animation):
	if animation == "ready":
		global.unpause()
		set_entities_visibility(true)
	elif animation == "warning":
		# Spawn bosses after the warning animation finished.
		if is_instance_valid(current_wave):
			current_wave.spawn_boss()


func _on_megaship_death() -> void:
	# Stop any animation or music.
	center_text.set_animation("none") 
	level_music.stop()
	boss_music.stop()
	game_over_timer.start()


func _on_megaship_transitioned(state_path: String) -> void:
	match state_path:
		"Move/Travel":
			if current_wave == null:
				# Start the first wave only. This is when the tp animation ends.
				next_wave()


func _on_GameOverTimer_timeout() -> void:
	level_data.current_wave_index -= 1
	if global.one_ups == 0:
		print(":(")
		global.game_over() # Resets lifes, e-tanks and points.
		
		ObjectRegistry.reset()
		
		# Go to game over screen.
		
		var inst = GAME_OVER_SCREEN.instance()
		inst.level_data = level_data
		get_tree().root.add_child(inst)
		get_tree().current_scene = inst
		queue_free()
		
	else:
		global.modify_stat("one_ups", -1)
		reload_level()


func _on_WaveTimer_timeout() -> void:
	snd_wave_help.play()
	ObjectRegistry.connect("enemy_registered", self, "_on_enemy_registered")
	for enemy in ObjectRegistry.get_enemies():
		create_enemy_pointer(enemy)


func _on_boss_registered(boss: Boss) -> void:
	# This is done for every enemy that inherits boss. Not all bosses
	# are spawned in the world as bosses, some of them spawn as normal
	# enemies but their hp must show on the global hud anyways.
	yield(boss, "ready")
	var hp_bar = bar_containter.new_boss_bar(boss.max_hp, boss.hp, Weapon.TYPES.HEAT)
	hp_bar.palette = boss.palette
	boss.hp_bar = hp_bar
	boss.connect("tree_exited", hp_bar, "queue_free")


func _on_main_boss_spawned(boss: Boss) -> void:
	# This is done only for those bosses spawned as a boss, not as a normal
	# enemy. This means that the boss music should start playing and, when
	# all of this bosses are killed, the level is completed.
	level_music.stop()
	boss_music.play()
	boss.connect("tree_exited", self, "_on_main_boss_tree_exited")


func _on_main_boss_tree_exited() -> void:
	# End the wave if the main boss is killed.
	current_wave.end()
	for enemy in ObjectRegistry.get_enemies():
		if enemy is Character:
			enemy.die()


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
	level_music.intro = music_intro
	level_music.loop = music_loop
	level_music.play()


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


func start_victory_animation() -> void:
	
	level_music.stop()
	boss_music.stop()
	
	megaship._state_machine.transition_to("Iddle")
	megaship.apply_propulsion_effects(Vector2.ZERO)
	camera.follow_none()
	victory_timer.start()
	
	global.is_paused = true
	
	yield(victory_timer, "timeout")
	
	victory_music.play()
	
	yield(victory_music, "finished")
	
	snd_victory_teleport.play()
	var final_position = Vector2(megaship.global_position.x, megaship.global_position.y -500)
	megaship._state_machine.transition_to("Move/Teleport", {"final_position": final_position})
	
	yield(megaship._state_machine, "transitioned")
	
	ObjectRegistry.reset()
	get_tree().change_scene(WEAPON_GET_SCREEN)
	
	global.is_paused = false


func next_wave() -> void:
	var wave_data = level_data.next_wave()
	if wave_data != null:
		# Spawn wave.
		current_wave = EnemyWave.new()
		current_wave.wave_data = wave_data
		current_wave.name = "EnemyWave"
		current_wave.connect("completed", self, "next_wave")
		current_wave.connect("main_boss_spawned", self, "_on_main_boss_spawned")
		game_layer.add_child(current_wave)
		# Create the enemy wave pointer so the player can find it.
		megaship.create_enemy_wave_pointer(current_wave, level_data.palette)
		
		wave_timer.start()
		# TODO: Play warning animation.
		center_text.set_animation("warning", 3)
	else:
		wave_timer.stop()
		print("muy bien!!")
		start_victory_animation()


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
	if is_instance_valid(megaship):
		megaship.create_enemy_pointer(enemy, level_data.palette)


func reload_level() -> void:
	name = "level_"
	disconnect("tree_exiting", self, "_on_tree_exiting")
	# Reset level.
	var inst = load(filename).instance()
	inst.level_data = level_data
	get_tree().root.call_deferred("add_child", inst)
	queue_free()


func _on_tree_exiting() -> void:
	global.unpause()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


