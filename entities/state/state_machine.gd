class_name StateMachine
extends Node

@onready var current_state: State = get_child(0)


func _ready() -> void:
	await owner.ready
	current_state.enter("")


func _physics_process(delta: float) -> void:
	current_state.process_physics(delta)


func transition_to(target_state_name: String) -> void:
	var next_state = get_node_or_null(target_state_name)
	if next_state == null or next_state == current_state:
		return
	current_state.exit()
	var prev_name = current_state.name
	current_state = next_state
	current_state.enter(prev_name)
