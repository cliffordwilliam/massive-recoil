# Base class for all state machine states.
class_name BaseState
extends Node

# I am readied first, but I can still get a reference to my parent.
@onready var state_machine: StateMachine = get_parent()


func _ready() -> void:
	Utils.require(state_machine is StateMachine, "BaseState: parent must be a StateMachine")


func enter(_old_state: StringName) -> void:
	pass


func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
