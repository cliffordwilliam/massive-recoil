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
## @onready var action_menu: ActionMenuState = $ActionMenuState
##
## func go_to_browse() -> void:
##     transition_to(browse)
## [/codeblock]
##
## For typed access to the concrete machine inside each state, create an intermediate
## base class that performs the cast once — see [InventoryBaseState] for the pattern.

## The initial state entered when the parent owner is ready.
## Must be a direct child of this node.
## Write-once — set once via the Inspector; crashes if reassigned or set to [code]null[/code].
@export var initial_state: BaseState:
	set(value):
		(
			Utils
			. require(
				value != null,
				"StateMachine.initial_state: must not be assigned null",
			)
		)
		(
			Utils
			. require(
				initial_state == null,
				"StateMachine.initial_state: write-once — already assigned",
			)
		)
		initial_state = value

## The currently active state. Private — transitions are the only valid way to change it.
var _current_state: BaseState = null


## Validates [member initial_state], asserts all children are [BaseState], sets
## [constant Node.PROCESS_MODE_DISABLED], then awaits the parent's [signal Node.ready]
## before restoring [constant Node.PROCESS_MODE_INHERIT] and entering [member initial_state].
##
## This function is a coroutine — the [code]await[/code] suspends it after initial validation
## so the parent can finish its [method Node._ready] normally before the machine starts.
func _ready() -> void:
	(
		Utils
		. require(
			initial_state is BaseState,
			"StateMachine._ready: initial_state is not assigned — set it in the Inspector",
		)
	)

	for c: Node in get_children():
		(
			Utils
			. require(
				c is BaseState,
				"StateMachine._ready: all children must be BaseState, got: " + c.name,
			)
		)

	(
		Utils
		. require(
			initial_state.get_parent() == self,
			"StateMachine._ready: initial_state must be a direct child of this node",
		)
	)

	# No null-check needed — initial_state was already verified to be a BaseState above.
	_current_state = initial_state

	# Disable processing until the parent owner is ready.
	process_mode = Node.PROCESS_MODE_DISABLED

	await get_parent().ready

	_current_state.enter(null)
	process_mode = Node.PROCESS_MODE_INHERIT


## Delegates [method BaseState.physics_update] to [member _current_state] each physics tick.
func _physics_process(delta: float) -> void:
	_current_state.physics_update(delta)


## Delegates [method BaseState.handle_input] to [member _current_state] on key events.
##
## Only fires for [InputEventKey] — no guard needed.
## Accepts [InputEvent] (not [InputEventKey]) because the Godot virtual method signature
## types the parameter as the base class even though only [InputEventKey] events are
## dispatched here. Narrowing to [InputEventKey] in the override or in
## [method BaseState.handle_input] would cause a type mismatch at the call site.
func _unhandled_key_input(event: InputEvent) -> void:
	_current_state.handle_input(event)


## Transitions from the current state to [param target].
## Calls [method BaseState.exit] on the outgoing state and [method BaseState.enter]
## on the incoming state. The outgoing state is passed to [method BaseState.enter]
## (or [code]null[/code] on the first entry from [method Node._ready]).
## Crashes if [param target] is the current state — self-transitions are not allowed.
## Crashes if [param target] is not a direct child of this node.
func transition_to(target: BaseState) -> void:
	(
		Utils
		. require(
			target.get_parent() == self,
			"StateMachine.transition_to: '%s' is not a direct child of this machine" % target.name,
		)
	)
	(
		Utils
		. require(
			target != _current_state,
			"StateMachine.transition_to: already in state: '%s'" % target.name,
		)
	)

	var previous_state: BaseState = _current_state
	_current_state.exit()
	_current_state = target
	_current_state.enter(previous_state)


## Delegates [method BaseState.draw] to [member _current_state].
## Call this from the owner's [method CanvasItem._draw] after drawing any elements
## that are always visible regardless of state.
func draw_state() -> void:
	_current_state.draw()


## Returns [code]true[/code] when the machine has started and is not already in
## [member initial_state].
## Check this before calling [method reset].
func can_reset() -> bool:
	return _current_state != null and _current_state != initial_state


## Resets to [member initial_state] by calling [method transition_to].
## Crashes if already at [member initial_state] — call [method can_reset] first.
## The explicit guard here produces a clearer error than the equivalent check inside
## [method transition_to] would.
func reset() -> void:
	Utils.require(can_reset(), "StateMachine.reset: already at initial_state")
	transition_to(initial_state)
