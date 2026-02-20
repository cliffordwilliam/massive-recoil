class_name StateMachine
extends Node

@onready var current_state: State = get_child(0)


func _ready() -> void:
	await owner.ready
	current_state.enter("")


func _physics_process(delta: float) -> void:
	current_state.process_physics(delta)


func transition_to(target_state_name: String) -> void:
	current_state.exit()
	var prev_name: StringName = current_state.name
	current_state = get_node(target_state_name)
	current_state.enter(prev_name)
