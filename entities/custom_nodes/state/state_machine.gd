class_name StateMachine
extends Node

@onready var current_state: BaseState = get_child(0)


func _ready() -> void:
	if not owner.is_node_ready():
		await owner.ready
	if current_state:
		current_state.enter("")


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process_physics(delta)


func exit_to(new_state_name: String, old_state_name: String) -> void:
	if current_state:
		current_state.exit()
	current_state = get_node_or_null(new_state_name)
	if current_state:
		current_state.enter(old_state_name)


func reset() -> void:
	exit_to(get_child(0).name, current_state.name if current_state else "")
