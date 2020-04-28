extends Node2D

const EXPLOTION_PARTICLE := preload("res://src/characters/death/explotion_particle.tscn")

var n_rotating_particles: int = 12
var angular_speed: float = 2 * PI
var radious: float = 20

var n_directions_to_explode: int = 16
var linear_speed: float = 120

var palette: int = 0

onready var explosion_timer := $ExplosionTimer
onready var snd_death := $SndDeath

func _ready() -> void:
	for i in range(n_rotating_particles):
		var dir := Vector2.RIGHT.rotated((2*PI / n_rotating_particles) * i)
		var inst := EXPLOTION_PARTICLE.instance()
		inst.velocity =  dir * radious * angular_speed
		inst.angular_speed = angular_speed
		inst.set_palette(palette)
		add_child(inst)
		

func explode():
	snd_death.play()
	for child in get_children():
		if child != snd_death and child != explosion_timer:
			child.queue_free()
	
	for i in range(n_directions_to_explode):
		var dir := Vector2.RIGHT.rotated((2*PI / n_directions_to_explode) * i)
		var inst := EXPLOTION_PARTICLE.instance()
		inst.velocity =  dir * linear_speed
		inst.set_palette(palette)
		add_child(inst)
		var inst2 := EXPLOTION_PARTICLE.instance()
		inst2.velocity =  dir * linear_speed / 1.6
		inst2.set_palette(palette)
		add_child(inst2)


func _on_explosion_timer_timeout() -> void:
	explode()

