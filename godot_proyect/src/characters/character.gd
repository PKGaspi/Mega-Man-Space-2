extends KinematicBody2D

onready var BARCONTAINER = $"/root/Space/GUILayer/Container/BarContainer"
# Bars.
const PROGRESS_BAR = preload("res://src/gui/progress_bar.tscn")
export(bool) var _hp_bar_show = true
export(bool) var _hp_bar_on_gui = false
export(int) var _hp_bar_palette = 0
export(Vector2) var _hp_bar_cell_size = Vector2(4, 2)
export(Vector2) var _hp_bar_position = Vector2(10, -8)
var hp_bar

export(NodePath) var snd_hit = "SndHit"
export(PackedScene) var death_instance = null

export(float) var hp_max = 10 # Max hp.
var hp : int # Hp.

var invencible : bool = false
var flickering : bool = false
var disappearing : bool = false

export (float) var invencibility_time = .5 # Seconds the character is invencible after hit.

var flickering_interval = .05 # Seconds between each visibility toggle when flickering.
var flickering_timer = 0 # Seconds until a toggle on visibility is made.
export(bool) var flicker_on_hit = true

export(float) var life_time = 10 # Seconds until the character disapears.
export(float) var life_flicker_time = 8 # Start flickering when the character has this many seconds of life.
export(bool) var flicker_before_timeout = false
export(bool) var dissapear_on_timeout = false

# Signals.
signal death

func _ready() -> void:
	hp = hp_max
	# Init HP bar.
	hp_bar = create_progress_bar(_hp_bar_cell_size, _hp_bar_position, hp_max, _hp_bar_show, _hp_bar_on_gui, _hp_bar_palette)
	
	# Init timers.
	if flicker_before_timeout:
		$LifeFlickeringTimer.start(life_flicker_time)
	if dissapear_on_timeout:
		$LifeTimer.start(life_time)

func _process(delta : float) -> void:
	pass

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

func create_progress_bar(cell_size : Vector2, pos : Vector2, max_value : float, show : bool = true, on_gui : bool = false, palette : int = 0):
	var bar = PROGRESS_BAR.instance()
	bar.init(cell_size, pos, max_value)
	bar.visible = show
	bar.set_palette(palette)
	
	if on_gui:
		BARCONTAINER.add_child(bar)
	else:
		add_child(bar)
		
	return bar

func set_visibility(value):
	visible = value

func get_visibility():
	return visible

func toggle_visibility():
	set_visibility(!get_visibility())

func set_hp(value):
	hp = clamp(value, 0, hp_max)
	
func set_hp_relative(relative_value):
	set_hp(hp + relative_value)

func flicker(interval = flickering_interval):
	$FlickeringTimer.start(interval)
	flickering = true
	toggle_visibility()

func hit(damage, weapon = global.WEAPONS.MEGA):
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
