extends Label

const FONT = preload("res://other/font.tres")

const READY_TEXT = "- READY -"
const READY_COLOR = Color("ebebeb")
const READY_SIZE = 8

const WARNING_TEXT = "_WARNING_"
const WARNING_COLOR = Color("b21030")
const WARNING_SIZE = 16

var animation_time : float  = 3
var animation_timer : float = 0

var flickering_interval : float = .15
var flickering_timer : float = 0

var alpha_max = 1
var alpha = 0
var alpha_min = 0
var alpha_multiplier = 4

var animation = "none"

signal animation_finished

func _process(delta: float) -> void:
	add_and_check_animation_time(delta)
	call(animation + "_animation", delta)
	pass

#################
## Animations. ##
#################

func ready_animation(delta : float) -> void:
	
	flickering_timer += delta
	if flickering_timer >= flickering_interval:
		flickering_timer = 0
		toggle_label_visibility()

func ready_init() -> void:
	set_label(READY_TEXT, READY_COLOR, READY_SIZE)

func warning_animation(delta : float) -> void:
	set_label_visibility(true)
	
	alpha = clamp(alpha + delta * alpha_multiplier, alpha_min, alpha_max)
	modulate.a = alpha
	if alpha == alpha_max or alpha == alpha_min:
		alpha_multiplier *= -1

func warning_init() -> void:
	set_label(WARNING_TEXT, WARNING_COLOR, WARNING_SIZE)
	
func none_animation(delta):
	pass

func none_init():
	visible = false
	pass

#########################
## Auxiliar functions. ##
#########################

func add_and_check_animation_time(delta : float) -> bool:
	var reached_time = false
	animation_timer += delta
	if animation_timer >= animation_time:
		emit_signal("animation_finished", animation)
		reached_time = true
		animation = "none"
		set_label_visibility(false)
	return reached_time

func set_animation(animation : String, duration : float = 3.0, listener : Object = null, listener_method : String = "") -> void:
	self.animation = animation
	self.animation_time = duration
	self.animation_timer = 0
	call(animation + "_init")
	
	if listener != null and listener.has_method(listener_method):
		connect("animation_finished", listener, listener_method)

func toggle_label_visibility() -> void:
	set_label_visibility(!visible)

func set_label_visibility(value : bool) -> void:
	visible = value
	
func set_label(text : String, color : Color, size : float) -> void:
	self.text = text
	self.modulate = color
	FONT.size = size