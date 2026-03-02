class_name BaseState
extends Node

@onready var state_machine: StateMachine = get_parent()


func enter(_old_state: Script) -> void:
	pass


func exit() -> void:
	pass


func process_physics(_delta: float) -> void:
	pass
