class_name StateMachine
extends Node

export var initial_state := NodePath()
export var initial_msg := Dictionary()
onready var state: State = get_node(initial_state) setget set_state

signal transitioned(state_path)


func _init() -> void:
	add_to_group("state_machine")


func _ready() -> void:
	yield(owner, "ready")
	assert(state != null)
	state.enter(initial_msg)


func _input(event: InputEvent) -> void:
	if state != null:
		state.input(event)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if state != null:
		state.unhandled_input(event)


func _process(delta: float) -> void:
	if state != null:
		state.process(delta)


func _physics_process(delta: float) -> void:
	if state != null:
		state.physics_process(delta)


func transition_to(target_state_path: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		print_debug("Warning: State %s doesn't exist." % target_state_path)
		return # Exit if there is no such state.
	
	var target_state = get_node(target_state_path)
	state.exit()
	set_state(target_state)
	state.enter(msg)
	
	emit_signal("transitioned", target_state)


func set_state(value: State) -> void:
	state = value
