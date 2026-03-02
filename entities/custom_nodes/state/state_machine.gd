class_name StateMachine
extends Node

var states: Dictionary[Script, BaseState] = { }
var current_state: BaseState = null
var initial_state: BaseState = null


func _ready() -> void:
	for c in get_children():
		if c is BaseState:
			states[c.get_script()] = c
			if not initial_state:
				initial_state = c
				current_state = c


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process_physics(delta)


func exit_to(new_state_script: Script, old_state_script: Script) -> void:
	var new_state: BaseState = states.get(new_state_script)
	if not new_state:
		push_warning("StateMachine: No child found for script: " + str(new_state_script))
		return
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(old_state_script)


func reset() -> void:
	if current_state and initial_state:
		exit_to(initial_state.get_script(), current_state.get_script())


# Safe: children _ready() before parent, so states dict is populated before Player.ready fires
func _on_player_ready() -> void: # Connected via engine GUI
	if current_state:
		current_state.enter(null)
