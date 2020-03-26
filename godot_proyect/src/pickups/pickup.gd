class_name Pickup
extends MoveableArea2D

# Stats.
export var stats: Resource

# Stat name that will be altered when picking up the pickup.
var affected_stat: String
# Who the stat affects.
var stat_owner: int
# Ammout to increment or decrement the affected_stat.
var ammount: float
# Time to flicker when the pickup is about to dissapear.
var flickering_time: float 
# Time before the pickup dissapears.
var life_time: float


onready var spr_icon = $SprIcon


func _ready() -> void:
	# Setup stats.
	assert(stats is StatsPickup)
	stats.initialize()
	
	affected_stat = stats.get_stat_name()
	stat_owner = stats.get_stat_owner()
	ammount = stats.get_stat("ammount")
	flickering_time = stats.get_stat("flickering_time")
	life_time = stats.get_stat("life_time")
	
	# Signals.
	
	if spr_icon is AnimatedPaletteSprite:
		global.MEGASHIP.connect("palette_changed", self, "_on_megaship_palette_change")
		spr_icon.set_palette(global.MEGASHIP.get_weapon())


func _on_body_entered(body: PhysicsBody2D) -> void:
	collide(body)


func collide(character: Character) -> void:
	character.modify_stat(affected_stat, stat_owner, ammount)
	queue_free()


func _on_megaship_palette_change(palette_index) -> void:
	spr_icon.set_palette(palette_index)
