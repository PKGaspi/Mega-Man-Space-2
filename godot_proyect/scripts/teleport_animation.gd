extends AnimatedSprite

const MEGASHIP = preload("res://scenes/megaship.tscn")
const TELEPORT_SPEED = 400 # In pixels per second.

export(SpriteFrames) var masks = null
export(SpriteFrames) var palettes = null

var palette : int = 0

export(Vector2) var destination = Vector2()

var dir : Vector2

func _ready() -> void:
	global.MEGASHIP = self
	play("falling")
	material.set_shader_param("mask", masks.get_frame(animation, frame))
	material.set_shader_param("palette", palettes.get_frame("default", palette))
	dir = global_position.direction_to(destination)
	pass

func _physics_process(delta: float) -> void:
	var movement = dir * TELEPORT_SPEED * delta
	var distance_total = global_position.distance_to(destination)
	var distance_to_move = global_position.distance_to(global_position + movement)
	if distance_to_move < distance_total:
		global_position += movement
	else:
		global_position = destination
		play("landing")
		
func _process(delta: float) -> void:
	material.set_shader_param("mask", masks.get_frame(animation, frame))
	if animation == "landing" and frame == 3:
		# Destroy and generate the ship.
		var ship = MEGASHIP.instance()
		ship.global_position = destination
		get_parent().add_child(ship)
		queue_free()
	pass
	