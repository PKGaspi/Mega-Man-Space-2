extends LinkButton


const FEEDBACK_URL = "https://docs.google.com/forms/d/e/1FAIpQLScQ2tUlVv-GYwLXbqw1VAcreJpN3U2nWt-7w1DzZx-SbRFyVg/viewform?usp=sf_link"


func _pressed() -> void:
	OS.shell_open(FEEDBACK_URL)
	global.exit_game()
