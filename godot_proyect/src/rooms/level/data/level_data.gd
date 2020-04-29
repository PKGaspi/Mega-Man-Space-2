class_name LevelData
extends Resource

export var name: String

export var music_intro: AudioStream
export var music_loop: AudioStream

export(Weapon.TYPES) var palette: int

export(Array, Resource) var enemy_waves: Array
var current_wave_index: int = -1

export(Weapon.TYPES) var main_weapon_unlocked: int
export(Weapon.TYPES) var secondary_weapon_unlocked: int


func initialize() -> void:
	current_wave_index = -1

# Returns the next wave. If there is no next wave,
# null should be returned instead.
func next_wave() -> EnemyWaveData:
	current_wave_index += 1
	var wave = null
	if current_wave_index < len(enemy_waves):
		wave = enemy_waves[current_wave_index]
	
	return wave


# Marks the main and secondary weapon of this level as unlocked.
func unlock_weapons() -> void:
	global.unlocked_weapons[main_weapon_unlocked] = true
	global.unlocked_weapons[secondary_weapon_unlocked] = true
