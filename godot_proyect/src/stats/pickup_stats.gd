class_name StatsPickup
extends Stats


enum OWNERS {
	GLOBAL,
	CHARACTER,
	CANNON,
}

enum TYPES {
	HP,
	MAX_HP,
	AMMO,
	MAX_AMMO,
	MAX_SPEED,
	BULLETS,
	CANNONS,
	ONE_UP,
	E_TANK
}

var type_owners = {
	TYPES.HP: OWNERS.CHARACTER,
	TYPES.MAX_HP: OWNERS.CHARACTER,
	
	TYPES.AMMO: OWNERS.CANNON,
	TYPES.MAX_AMMO: OWNERS.CANNON,
	TYPES.MAX_SPEED: OWNERS.CANNON,
	TYPES.BULLETS: OWNERS.CANNON,
	TYPES.CANNONS: OWNERS.CANNON,
	
	TYPES.ONE_UP: OWNERS.GLOBAL,
	TYPES.E_TANK: OWNERS.GLOBAL,
}

var type_names = {
	TYPES.HP: "hp",
	TYPES.MAX_HP: "max_hp",
	
	TYPES.AMMO: "ammo",
	TYPES.MAX_AMMO: "max_ammo",
	TYPES.MAX_SPEED: "max_speed",
	TYPES.BULLETS: "max_bullets",
	TYPES.CANNONS: "n_cannons",
	
	TYPES.ONE_UP: "one_ups",
	TYPES.E_TANK: "e_tanks",
}


# Stat name that will be altered when picking up the pickup.
export(TYPES) var affected_stat
# Ammout to increment or decrement the affected_stat.
export var ammount: float = 5
# Time to flicker when the pickup is about to dissapear.
export var flickering_time: float = 3
# Time before the pickup dissapears.
export var life_time: float = 12
# Max speed.
export var max_speed: float = 20


func get_stat_name(stat := affected_stat) -> String:
	return type_names[affected_stat]


func get_stat_owner(stat := affected_stat) -> int:
	return type_owners[stat]
