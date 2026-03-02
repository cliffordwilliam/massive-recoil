class_name StateMachine
extends Node

var states: Dictionary[Script, BaseState] = { }

@onready var current_state: BaseState = get_child(0)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process_physics(delta)


func exit_to(new_state_script: Script, old_state_script: Script) -> void:
	var new_state: BaseState = states.get(new_state_script)
	if not new_state:
		push_warning("StateMachine: No child found for script ", new_state_script)
		return
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(old_state_script)


func reset() -> void:
	if current_state and get_child_count():
		exit_to(get_child(0).get_script(), current_state.get_script())


func _on_player_ready() -> void: # Connected via engine GUI
	for child: BaseState in get_children():
		states[child.get_script()] = child
	if current_state:
		current_state.enter(null)
