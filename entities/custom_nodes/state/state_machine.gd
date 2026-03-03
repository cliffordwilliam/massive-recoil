# State machine to manage BaseState
class_name StateMachine
extends Node

@export var initial_state: BaseState

var current_state: BaseState = null


func _ready() -> void:
	assert(initial_state is BaseState, "StateMachine: Initial state must be BaseState")

	current_state = initial_state

	for c in get_children():
		assert(c is BaseState, "StateMachine: I can only have BaseState children")

	assert(get_child_count() > 0, "StateMachine: I have no state children")


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	# This game uses keyboard input only
	if event is not InputEventKey:
		return

	if current_state:
		current_state.handle_input(event)


func transition_to(target_state_name: StringName, previous_state: StringName) -> void:
	var target_state: BaseState = get_node(NodePath(target_state_name))
	assert(target_state is BaseState, "StateMachine: No child found for: " + target_state_name)

	if current_state:
		current_state.exit()

	current_state = target_state
	current_state.enter(previous_state)


func reset() -> void:
	if current_state and initial_state:
		transition_to(initial_state.name, current_state.name)


# WARNING: Must be called by owner ready!
# Empty StringName means this is the first ever state entry (no previous state)
func start() -> void: # Connected via engine GUI
	if current_state:
		current_state.enter(&"")
