extends Label

const READY_TEXT := "- READY -"
const READY_COLOR := Color("ebebeb")
const READY_SIZE := 8
const READY_FLICKERING_INTERVAL: float = 8.0/60.0

const WARNING_TEXT := "_WARNING_"
const WARNING_BOTTOM_TEXT_GENERIC: Resource = preload("res://src/gui/texts/warning_bottom_text_generic.tres")
const WARNING_BOTTOM_TEXT_BOSS := "BOSS INCOMING"
const WARNING_COLOR := Color("b21030")
const WARNING_SIZE := 16

var animation_timer: Timer
var flickering_timer: Timer

var alpha_max = 1
var alpha = 0
var alpha_min = 0
var alpha_multiplier = 4

var animation = "none"

signal animation_finished(animation_name)


func _ready() -> void:
	# Setup timers.
	animation_timer = Timer.new()
	animation_timer.name = "AnimationTimer"
	animation_timer.one_shot = true
	add_child(animation_timer)
	
	flickering_timer = Timer.new()
	flickering_timer.name = "FlickeringTimer"
	flickering_timer.one_shot = true
	add_child(flickering_timer)


func _process(delta: float) -> void:
	call(animation + "_animation", delta)
	if animation_has_finished():
		var old_animation = animation 
		set_animation("none")
		emit_signal("animation_finished", old_animation)


#################
## Animations. ##
#################


func ready_animation(delta : float) -> void:
	
	if flickering_timer.is_stopped():
		flickering_timer.start()
		toggle_label_visibility()


func ready_init() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	set_label(READY_TEXT, READY_COLOR, READY_SIZE)
	flickering_timer.wait_time = READY_FLICKERING_INTERVAL
	flickering_timer.start()


func warning_animation(delta : float) -> void:
	set_label_visibility(true)
	
	alpha = clamp(alpha + delta * alpha_multiplier, alpha_min, alpha_max)
	modulate.a = alpha
	if alpha == alpha_max or alpha == alpha_min:
		alpha_multiplier *= -1


func warning_init() -> void:
	pause_mode = Node.PAUSE_MODE_STOP
	set_label(WARNING_TEXT, WARNING_COLOR, WARNING_SIZE)


func none_animation(delta):
	pass


func none_init():
	set_label_visibility(false)


#########################
## Auxiliar functions. ##
#########################


func animation_has_finished() -> bool:
	return animation_timer.is_stopped()


func set_animation(animation : String, duration : float = 3.0) -> void:
	self.animation = animation
	animation_timer.start(duration)
	call(animation + "_init")


func toggle_label_visibility() -> void:
	set_label_visibility(!visible)


func set_label_visibility(value : bool) -> void:
	visible = value


func set_label(text : String, color : Color, size : float) -> void:
	self.text = text
	self.modulate = color
	get_font("font").size = size
