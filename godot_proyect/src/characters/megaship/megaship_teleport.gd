extends AnimatedSprite

const TELEPORT_SPEED = 400 # In pixels per second.

export(SpriteFrames) var masks = null
export(SpriteFrames) var palettes = null

var palette : int = 0

export(Vector2) var destination = Vector2()

var dir : Vector2

func _ready() -> void:
	global.MEGASHIP.visible = false
	play("teleport_falling")
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
	elif animation == "teleport_falling":
		global_position = destination
		play("teleport_landing")
		$"../SndTeleport".play()
		
func _process(delta: float) -> void:
	print(frames.get_animation_speed(animation))
	material.set_shader_param("mask", masks.get_frame(animation, frame))
	if animation == "teleport_landing" and frame == 3:
		# Destroy.
		global.MEGASHIP.visible = true
		queue_free()
	pass
	