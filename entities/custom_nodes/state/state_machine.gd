class_name StateMachine
extends Node

@onready var current_state: State = get_child(0)


func _ready() -> void:
	await owner.ready
	current_state.enter("")


func _physics_process(delta: float) -> void:
	current_state.process_physics(delta)


func exit_to(new_state_name: String, old_state_name: String) -> void:
	current_state.exit()
	current_state = get_node(new_state_name)
	current_state.enter(old_state_name)
