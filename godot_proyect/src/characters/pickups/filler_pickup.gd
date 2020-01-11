extends "res://src/characters/pickups/pickup.gd"

var prefix : String = ""

const CHANCES = {
	"heal": .4,
	"ammo": .4,
	"1up": .1,
	"e-tank": .1,
}

const AMMOUNTS = {
	"heal": 7.0,
	"ammo": 7.0,
	"1up": 1.0,
	"e-tank": 1.0,
}

const HAS_SMALL = {
	"heal": true,
	"ammo": true,
	"1up": false,
	"e-tank": false,
}

const SMALL_AMMOUNT_OFFSET = -4

const SMALL_CHANCE = .7

func _ready() -> void:
	$Sprite.material = $Sprite.material.duplicate()
	$AnimatedSprite.play(type)
	$Sprite.texture = global.create_empty_image(masks.get_frame(prefix + type, 0).get_size())
	set_palette(0)
	if global.MEGASHIP != null:
		# Conect palette change signal.
		global.MEGASHIP.connect("palette_change", self, "_on_megaship_palette_change")
		set_palette(global.MEGASHIP.active_weapon)
	
func init(pos : Vector2, type : String = "", ammount : float = 0, small : bool = false) -> void:
	self.global_position = pos
	if type == "":
		small = set_random_type()
	else:
		self.type = type
		self.ammount = ammount
	if small:
		prefix = "small_"
		$CollisionBox.queue_free()
	else:
		$SmallCollisionBox.queue_free()

func _on_megaship_palette_change(palette_index) -> void:
	set_palette(palette_index)

func _on_animated_sprite_frame_changed() -> void:
	set_mask($AnimatedSprite.frame)

func set_random_type() -> bool:
	var small = false
	var val = random.randf()
	var total_val = 0
	for key in CHANCES.keys():
		total_val += CHANCES[key]
		if val <= total_val:
			self.type = key
			break
	self.ammount = AMMOUNTS[type]
	
	if HAS_SMALL[type] && random.randf() < SMALL_CHANCE:
		self.ammount += SMALL_AMMOUNT_OFFSET
		small = true
	return small

func collide(collider) -> void:
	collider.fill(type, ammount)
	disappear()

func set_mask(mask_index) -> void:
	$Sprite.material.set_shader_param("mask", masks.get_frame(prefix + type, mask_index))

func set_palette(palette_index):
	$Sprite.material.set_shader_param("palette", palettes.get_frame("default", palette_index))