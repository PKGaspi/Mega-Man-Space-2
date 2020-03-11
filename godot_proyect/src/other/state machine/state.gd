class_name State
extends Node


onready var _state_machine: = _get_state_machine()

# Using the same class, i.e. State, as a type hint causes a memory leak in Godot
# 3.2.
var _parent_state = null # Null if the parent is the state machine.


func _ready() -> void:
	yield(owner, "ready")
	var parent = get_parent()
	if not parent.is_in_group("state_machine"):
		_parent_state = parent


func unhandled_input(event: InputEvent) -> void:
	if _parent_state != null:
		_parent_state.unhandled_input(event)


func process(delta: float) -> void:
	if _parent_state != null:
		_parent_state.process(delta)


func physics_process(delta: float) -> void:
	if _parent_state != null:
		_parent_state.physics_process(delta)


func enter(msg := {}) -> void:
	pass


func exit() -> void:
	pass


func _get_state_machine(node: Node = self) -> Node:
	if node != null and not node.is_in_group("state_machine"):
		return _get_state_machine(node.get_parent())
	return node
