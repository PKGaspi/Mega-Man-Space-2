extends KinematicBody2D

const UPGRADE = preload("res://scenes/upgrade.tscn")

onready var LIB = get_node("/root/library")

const INVENCIBILITY_TIME = .5 # In seconds.
const FLICKERING_INTERVAL = .05 # In seconds.

var upgrade_chance = .2

var max_hp = 30
var hp = max_hp
var invencibitity_timer = 0 # Seconds until this enemy can be hit again.
var flickering_timer = 0 # Seconds until a toggle on visibility is made.
var dead = false


func _process(delta):
	if !dead:
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
	else:
		if !$SndHit.playing:
			# Destroy totally when sound stops.
			queue_free()

func init(pos):
	global_position = pos

func hit(bullet):
	if !is_invincible():
		take_damage(bullet.damage)
	
func take_damage(damage):
	LIB.play_audio_random_pitch($SndHit, Vector2(.90, 1.10))
	hp -= damage
	invencibitity_timer = INVENCIBILITY_TIME
	check_death()

func check_death():
	if hp <= 0:
		die()
	
func die():
	# Tell the enemy generator I died.
	get_parent().count_death()
	# Generate and upgrade at random.
	if randf() <= .2:
		var inst = UPGRADE.instance()
		inst.global_position = global_position
		get_tree().root.add_child(inst)
	# Destroy myself.
	dead = true
	$CollisionShape2D.queue_free()
	$Sprite.queue_free()
	
func is_invincible():
	return invencibitity_timer > 0