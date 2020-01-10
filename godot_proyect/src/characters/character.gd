extends KinematicBody2D

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
	if flicker_before_timeout:
		$LifeFlickeringTimer.start(life_flicker_time)
	if dissapear_on_timeout:
		$LifeTimer.start(life_time)
	pass

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

func set_visibility(value):
	visible = value

func get_visibility():
	return visible

func toggle_visibility():
	set_visibility(!get_visibility())

func update_bar(bar, new_value, new_max_value, pause : bool = false) -> void:
	if pause:
		bar.update_values(new_value, new_max_value)
	else:
		bar.update_values(new_value, new_max_value, 0)

func flicker(interval = flickering_interval):
	$FlickeringTimer.start(interval)
	flickering = true
	toggle_visibility()

func hit(bullet):
	if !invencible:
		# TODO: Calculate damage with enemy weakness and bullet weapon type.
		var damage = bullet.damage
		take_damage(damage)

func take_damage(damage):
	# Play hit sound.
	global.play_audio_random_pitch(get_node(snd_hit), Vector2(.90, 1.10))
	hp -= damage
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
