extends KinematicBody2D

onready var SND_HIT = get_node("SndHit")
onready var LIB = get_node("/root/library")

const INVENCIBILITY_TIME = .5 # In seconds.
const FLICKERING_INTERVAL = .05 # In seconds.

var max_hp = 30
var hp = max_hp
var invencibitity_timer = 0 # Seconds until this enemy can be hit again.
var flickering_timer = 0 # Seconds until a toggle on visibility is made.

func _process(delta):
	# Calculate invencibility and filckering.
	invencibitity_timer = max(invencibitity_timer - delta, 0)
	if invencibitity_timer > 0:
		if flickering_timer <= 0:
			# Toggle flicker.
			$Sprite.visible = !$Sprite.visible
			flickering_timer = FLICKERING_INTERVAL
		else:
			flickering_timer = max(flickering_timer - delta, 0)
	else:
		# Stop at a visible state.
		$Sprite.visible = true

func init(pos):
	global_position = pos

func hit(bullet):
	if !is_invincible():
		take_damage(bullet.damage)
	
func take_damage(damage):
	LIB.play_audio_random_pitch(SND_HIT, Vector2(.9, 1.1))
	hp -= damage
	invencibitity_timer = INVENCIBILITY_TIME
	check_death()

func check_death():
	if hp <= 0:
		die()
	
func die():
	get_parent().count_death()
	queue_free()
	
func is_invincible():
	return invencibitity_timer > 0