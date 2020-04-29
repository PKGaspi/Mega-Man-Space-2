extends Node

const FILE_PATH := "user://stats.txt"
var file: File = File.new()

const SEPARATOR := "-------------------------\n"

var session: int
var time_played: float

var enemies_spawned: Dictionary # Number of times each enemy spawned.
var pickups_spawned: Dictionary # Number of times each pickup spawned.
var damage_dealt: float
var damage_received: Dictionary # Damage dealt by each type of enemy.
var distance_traveled: float
var deaths: int # Number of times that the player died.


func _init() -> void:
	session = OS.get_unix_time()


func _physics_process(delta: float) -> void:
	time_played += delta


func save() -> void:
	# Open stats file.
	
	var err
	if file.file_exists(FILE_PATH):
		err = file.open(FILE_PATH, File.READ_WRITE)
	
	else:
		err = file.open(FILE_PATH, File.WRITE)
	
	if err != OK:
		printerr("Error(%d): Couldn't open or create stats file." % err)
		return
	
	
	# Write the file.
	file.seek_end()
	
	file.store_string(SEPARATOR)
	
	file.store_string("Session: %d\n" % session)
	
	file.store_string("Time played (min): %d\n" % int(round(time_played / 60)))
	
	file.store_string("Deaths: %d\n" % deaths)
	
	file.store_string("Enemies spawned:\n")
	for enemy in enemies_spawned:
		file.store_string(enemy + ": \t\t%d\n" % enemies_spawned[enemy])
	
	file.store_string("Pickups spawned:\n")
	for pickup in pickups_spawned:
		file.store_string(pickup + ": \t\t%d\n" % pickups_spawned[pickup])
	
	file.store_string("Damage received per source:\n")
	for source in damage_received:
		file.store_string(source + ": \t\t%d\n" % damage_received[source])
	
	file.store_string("Damage dealt: %s\n" % damage_dealt)
	
	file.store_string("Distance traveled: %d\n" % distance_traveled)
	
	file.store_string(SEPARATOR)
	
	
	file.close()
