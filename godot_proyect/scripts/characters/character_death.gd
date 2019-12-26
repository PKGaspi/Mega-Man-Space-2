extends Sprite

var visible_time : float = .3 # Time that the sprite is visible in seconds.
var life_timer : float = 0

func _ready() -> void:
	print("holi")
	$SndDeath.play()
	pass

func _process(delta: float) -> void:
	life_timer += delta
	
	if life_timer >= visible_time:
		visible = false
		if !$SndDeath.playing:
			queue_free()