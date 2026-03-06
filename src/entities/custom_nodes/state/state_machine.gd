# State machine to manage BaseState.
class_name StateMachine
extends Node

@export var initial_state: BaseState

var current_state: BaseState = null
var states: Dictionary[StringName, BaseState] = { }


func _ready() -> void:
	if not Utils.require(
		initial_state is BaseState,
		"StateMachine: Initial state must be BaseState",
	):
		return

	if not Utils.require(get_child_count() > 0, "StateMachine: I have no state children"):
		return

	for c in get_children():
		if not Utils.require(
			c is BaseState,
			"StateMachine: I can only have BaseState children, got: " + c.name,
		):
			continue
		states[c.name] = c

	current_state = initial_state

	# Disable processing until start() is called by the owner's _ready().
	set_physics_process(false)
	set_process_unhandled_input(false)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	# This game uses keyboard input only.
	if event is not InputEventKey:
		return

	if current_state:
		current_state.handle_input(event)


func transition_to(target_state_name: StringName, previous_state: StringName) -> void:
	if not Utils.require(states.has(target_state_name), "StateMachine: No state found for: " + target_state_name):
		return

	var target_state: BaseState = states[target_state_name]

	if current_state:
		current_state.exit()

	current_state = target_state
	current_state.enter(previous_state)


func reset() -> void:
	if current_state and initial_state:
		transition_to(initial_state.name, current_state.name)


# Warning: Must be called by the owner's _ready.
# An empty StringName as the previous state means this is the initial entry.
func start() -> void:
	set_physics_process(true)
	set_process_unhandled_input(true)

	if current_state:
		current_state.enter(&"")
