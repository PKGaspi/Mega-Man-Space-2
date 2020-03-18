class_name Upgrade
extends Pickup

const NEGATIVE_FREQUENCY = .5

const MOVE_SPEED_POS = 10
const MOVE_SPEED_NEG = 40

var bad : bool = ammount < 0 # Whether the pickpup is bad or good.

enum TYPES {
	HP,
	SPEED,
	N_SHOOTS,
	BULLET_MAX,
	LENGTH,
}

var UPGRADE_TYPES = {
	TYPES.HP: "hp_max",
	TYPES.SPEED: "speed",
	TYPES.N_SHOOTS: "n_cannons",
	TYPES.BULLET_MAX: "bullet_max",
}

var UPGRADE_AMMOUNTS = {
	TYPES.HP: 2.0,
	TYPES.SPEED: 30,
	TYPES.N_SHOOTS: 1.0,
	TYPES.BULLET_MAX: 1.0,
}

const SPRITES = preload("res://resources/characters/pickups/upgrades_sprites.tres")

export(TYPES) var index = -1

func _ready():
	
	set_type(index)
	
	# Maybe this upgrade is negative.
	if random.randf() <= NEGATIVE_FREQUENCY:
		# The upgrade is bad.
		toggle_upgrade()
	else:
		# The upgrade is good.
		# Shine for the first time.
		$SprShine.play("shine")
		hp_bar.visible = false # Hide UPGRADES.HP bar if good.

func init(pos : Vector2, index : int = -1, ammount : float = 0) -> void:
	self.global_position = pos
	if index >= 0:
		set_type(index)
	else:
		set_random_upgrade()
	self.ammount = get_default_ammount(self.index) if ammount == 0 else ammount

func _on_shine_timer_timeout() -> void:
	shine()
#########################
## Auxiliar functions. ##
#########################

func set_random_upgrade() -> void:
	set_type(random.randi_range(0, TYPES.LENGTH - 1))

func set_type(new_index) -> void:
	if new_index < 0 or new_index >= TYPES.LENGTH:
		set_random_upgrade()
		return
	index = new_index
	type = UPGRADE_TYPES[index]
	ammount = get_default_ammount()
	bad = ammount <= 0
	set_sprites()

func get_default_ammount(index : int = self.index) -> float:
	return UPGRADE_AMMOUNTS[index]

func set_sprites():
	$SprIcon.texture = SPRITES.get_frame("icons", index)
	$Sprite.texture = SPRITES.get_frame("shells", 1 if bad else 0)
	
func shine():
	$SprShine.frame = 0 # Shine.
	if !bad:
		$SprShine.play("default")
	else:
		$SprShine.stop()

func toggle_upgrade():
	# Change values.
	ammount = -ammount
	bad = !bad
	# Restart timer.
	$LifeTimer.start(life_time)
	$LifeFlickeringTimer.start(life_flicker_time)
	# Set collision, sprites and more.
	set_collision_layer_bit(2, bad)
	set_sprites()
	hp_bar.visible = bad # Hide UPGRADES.HP bar if good.
	flickering = false
	if bad:
		follow_megaship()
		$SprShine.stop()
		move_speed = MOVE_SPEED_NEG
	else:
		to_follow = null
		$SprShine.play("shine")
		move_speed = MOVE_SPEED_POS

func die():
	hp = max_hp
	toggle_upgrade()
	

func collide(collider):
	collider.upgrade(type, ammount)
	if bad:
		.collide(collider)
	disappear()
