extends Node

const GAME_OVER_WAIT_TIME = 5 # In seconds.

const MEGASHIP_TELEPORT = preload("res://src/characters/megaship/megaship_teleport.tscn")
const WEAPONS_MENU = preload("res://src/gui/menus/weapon menu/weapon_menu.tscn")

onready var music_looper = get_node("MusicLooper")

var lvl_id = 0 # This is set when selecting the level.

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

func _ready() -> void:
	get_tree().current_scene = self
	global.connect("user_pause", self, "_on_global_user_pause")
	$GameLayer/Megaship.connect("death", self, "_on_megaship_death")
	
	set_music(lvl_id)
	start_ready_animation()


func _on_animation_finished(animation):
	if animation == "ready":
		global.create_touchscreen_layout($GUILayer/Container)
		$GameLayer/TeleportAnimation.pause_mode = PAUSE_MODE_PROCESS
		# Disable static camera.
		$GameLayer/StaticCamera.queue_free()
		$GameLayer/Megaship/Camera2D.current = true

func _on_teleport_animation_tree_exiting() -> void:
	global.unpause()
	$GameLayer/EnemyGenerator.new_random_horde()

func _on_megaship_death() -> void:
	death()

func _on_boss_death() -> void:
	# TODO: Go to the select screen.
	pass
	
func _on_game_over_timer_timeout() -> void:
	global.lifes -= 1
	if global.lifes < 0:
		print(":(")
		global.game_over()
		# TODO: Go to game over screen and reset points.
	get_tree().reload_current_scene()

func _on_global_user_pause(value) -> void:
	$GUILayer/Container.visible = !value
	$GameLayer.visible = !value
	if !value: # Game is unpaused.
		global.MEGASHIP.visible = false
		var inst = MEGASHIP_TELEPORT.instance()
		var ship_pos = global.MEGASHIP.global_position
		inst.global_position = ship_pos
		inst.destination = ship_pos
		$GameLayer.add_child(inst)
	else: # Game is paused.
		create_weapons_menu()
	
func set_music(music_index: int) -> void:
	if music_intros.has(lvl_id) and music_loops.has(lvl_id):
		var intro = music_intros[lvl_id]
		var loop = music_loops[lvl_id]
		music_looper.intro = intro
		music_looper.loop = loop
		music_looper.play()

func start_ready_animation():
	$GUILayer/Container/CenterContainer/CenterText.set_animation("ready", 3, self, "_on_animation_finished")
	global.pause()

func create_weapons_menu() -> void:
	var inst = WEAPONS_MENU.instance()
	inst.set_palette(lvl_id)
	var weapon_index = global.MEGASHIP.active_weapon
	var unlocked_weapons = global.MEGASHIP.unlocked_weapons
	var unlocked_entries = {}
	for i in range(12):
		# Create dictionary with the unlocked entries. Key is a vector2 with
		# page-entry and value is a boolean true if unlocked.
		unlocked_entries[Vector2(floor(i / 6), 1 + i % 6)] = unlocked_weapons[i]
	inst.unlocked_entries = unlocked_entries
	$GUILayer.add_child(inst)
	yield(inst, "opened")
# warning-ignore:unused_variable
	# Set active entry of the current weapon.
	for i in range(floor(weapon_index / 6)):
		inst.next_page()
	inst.set_entry((weapon_index % 6) + 1)

func death() -> void:
	$GUILayer/Container/CenterContainer/CenterText.set_animation("none")
	music_looper.stop()
	$GameOverTimer.start(GAME_OVER_WAIT_TIME)
	
	# TODO: Start timer for game over screen or something like that.

