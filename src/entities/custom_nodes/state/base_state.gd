class_name BaseState
extends Node

# Base class for all state machine state
# I readied first but then I still can get parent reference
@onready var state_machine: StateMachine = get_parent()


func enter(_old_state: StringName) -> void:
	pass


func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
