class_name StateMachine
extends Node
## Generic finite state machine.
##
## Manages a set of [BaseState] child nodes and drives transitions between them.
## Add [BaseState] nodes as children in the scene tree and set [member initial_state]
## in the Inspector. The machine must be a direct child of its owner — it starts
## automatically once the parent emits its [signal Node.ready].
##
## [b]Usage:[/b] Create a concrete subclass for each state machine. The subclass holds
## typed [code]@onready[/code] references to each child state and exposes named transition
## methods. Transition methods pass the typed child reference directly to [method transition_to],
## which avoids raw [StringName] literals and makes the call site type-safe.
##
## [codeblock]
## class_name InventoryStateMachine
## extends StateMachine
##
## @onready var browse: BrowseState = $BrowseState
## @onready var _action_menu: ActionMenuState = $ActionMenuState
##
## func go_to_browse() -> void:
##     transition_to(browse)
## [/codeblock]
##
## For typed access to the concrete machine inside each state, create an intermediate
## base class that performs the cast once — see [InventoryBaseState] for the pattern.

## The initial state entered when the parent owner is ready. Set in the Inspector.
@export var initial_state: BaseState

## The currently active state. Transitions are the only valid way to change it.
var current_state: BaseState = null


## Disables processing until the parent owner is ready, then enters [member initial_state].
func _ready() -> void:
	assert(initial_state is BaseState, "initial_state not set in Inspector")
	current_state = initial_state
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_parent().ready
	current_state.enter(null)
	process_mode = Node.PROCESS_MODE_INHERIT


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


## Only fires for [InputEventKey] — accepts [InputEvent] because Godot's virtual method
## signature types the parameter as the base class.
func _unhandled_key_input(event: InputEvent) -> void:
	current_state.handle_input(event)


## Transitions from the current state to [param target].
func transition_to(target: BaseState) -> void:
	var previous_state: BaseState = current_state
	current_state.exit()
	current_state = target
	current_state.enter(previous_state)


## Delegates [method BaseState.draw] to [member current_state].
func draw_state() -> void:
	current_state.draw()


## Resets to [member initial_state].
func reset() -> void:
	transition_to(initial_state)
