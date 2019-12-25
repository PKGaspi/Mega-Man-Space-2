extends CenterContainer

const READY_TEXT = "- READY -"

var pause_time : float  = 3
var pause_timer : float = 0

var flickering_interval : float = .15
var flickering_timer : float = 0

func process_ready_text(delta : float) -> bool:
	set_label_text(READY_TEXT)
	var finished
	pause_timer += delta
	if pause_timer > pause_time:
		finished = true
		set_text_visibility(false)
	else:
		finished = false
		flickering_timer += delta
		if flickering_timer >= flickering_interval:
			flickering_timer = 0
			toggle_text_visibility()
	return finished

func toggle_text_visibility() -> void:
	set_text_visibility(!$Label.visible)

func set_text_visibility(value : bool) -> void:
	$Label.visible = value
	
func set_label_text(text : String) -> void:
	$Label.text = text