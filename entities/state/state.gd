class_name State
extends Node

@onready var parent_node: StateMachine = get_parent()

func enter(_prev_state: String) -> void:
	pass

func exit() -> void:
	pass

func process_physics(_delta: float) -> void:
	pass
