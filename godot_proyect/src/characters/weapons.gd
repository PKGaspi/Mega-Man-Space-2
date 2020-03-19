class_name Weapon
extends Resource

# Weapons.
enum TYPES {
	MEGA,
	HEAT,
	AIR,
	WOOD,
	BUBBLE,
	QUICK,
	FLASH,
	METAL,
	CRASH,
	ONE,
	TWO,
	THREE,
}

export(TYPES) var type := TYPES.MEGA
