extends KinematicBody2D

onready var snd_hit = $SndHit # Node with the hit sound.
onready var snd_death = $"../SndDeath"

export(int) var hp_max = 28 # Max hp.
var hp = hp_max # Hp.

var invencibility_time = .5 # Seconds the character is invencible after hit.
var invencibitity_timer = 0 # Seconds until this enemy can be hit again.

var flickering_interval = .05 # Seconds between each visibility toggle when flickering.
var flickering_timer = 0 # Seconds until a toggle on visibility is made.
export(bool) var flicker_on_hit = true

const life_time = 10 # Seconds until the character disapears.
const life_flicker_time = 8 # Start flickering when the character has this many seconds of life.
var life_timer = 0
export(bool) var flicker_before_timeout = false
export(bool) var dissapear_on_timeout = false

func _ready():
	pass

func _process(delta):
	# Check if the character disapears this frame. <-- This was Álex's idea.
	life_timer += delta
	if dissapear_on_timeout and life_timer >= life_time:
		disappear()
		
	# Calculate invencibility and filckering.
	invencibitity_timer = max(invencibitity_timer - delta, 0)
	if is_invincible() or (life_timer >= life_flicker_time and flicker_before_timeout):
		# Flicker.
		if flickering_timer <= 0:
			# Toggle flicker.
			toggle_visibility()
			flickering_timer = flickering_interval
		else:
			flickering_timer = max(flickering_timer - delta, 0)
	else:
		# Stop flickering.
		set_visibility(true)


#########################
## Auxiliar functions. ##
#########################

func set_visibility(value):
	visible = value

func toggle_visibility():
	visible = !visible

func hit(bullet):
	if !is_invincible():
		# TODO: Calculate damage with enemy weakness and bullet weapon type.
		var damage = bullet.damage
		take_damage(damage)

func take_damage(damage):
	# Play hit sound.
	global.play_audio_random_pitch(snd_hit, Vector2(.90, 1.10))
	hp -= damage
	invencibitity_timer = invencibility_time
	check_death()

func check_death():
	if hp <= 0:
		# Oh wow I'm dead.
		die()

func die():
	# Destroy myself by default.
	snd_death.play()
	queue_free()
	
func disappear():
	# Destroy myself by default.
	queue_free()

func is_invincible() -> bool:
	return invencibitity_timer > 0