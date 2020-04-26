extends LinkButton


const FEEDBACK_URL = "http://godotengine.org"


func _pressed() -> void:
	OS.shell_open(FEEDBACK_URL)
