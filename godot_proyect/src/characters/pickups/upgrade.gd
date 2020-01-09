extends "res://src/characters/pickups/pickup.gd"

const NEGATIVE_FREQUENCY = .5

const MOVE_SPEED_POS = 10
const MOVE_SPEED_NEG = 40

const SHINE_TIME_MIN = 2 # In seconds.
const SHINE_TIME_MAX = 5 # In seconds.

enum {
	HP,
	SPEED,
	N_SHOOTS,
	BULLET_MAX,
	UPGRADES_LENGTH,
}

var UPGRADE_TYPES = {
	HP: "hp_max",
	SPEED: "UPGRADES.SPEED_multiplier",
	N_SHOOTS: "n_cannons",
	BULLET_MAX: "UPGRADES.BULLET_MAX",
}

var UPGRADE_AMMOUNTS = {
	HP: 2,
	SPEED: .2,
	N_SHOOTS: 1,
	BULLET_MAX: 1,
}

const SPRITES = preload("res://resources/pickups/upgrades_sprites.tres")

var index = -1

func _ready():
	
	if index < 0:
		set_random_upgrade()
	
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
	if ammount != 0:
		self.ammount = ammount

#########################
## Auxiliar functions. ##
#########################

func set_random_upgrade() -> void:
	set_type(random.randi_range(0, UPGRADES_LENGTH - 1))

func set_type(new_index) -> void:
	self.index = new_index
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
		to_follow = global.MEGASHIP
		to_follow.connect("tree_exiting", self, "_on_to_follow_tree_exiting")
		$SprShine.stop()
		move_speed = MOVE_SPEED_NEG
	else:
		to_follow = null
		$SprShine.play("shine")
		move_speed = MOVE_SPEED_POS

func die():
	life_timer = 0 # Reset life_timer.
	hp = hp_max
	toggle_upgrade()
	

func _on_shine_timer_timeout() -> void:
	shine()
