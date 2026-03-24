class_name StateMachine
extends Node
## Generic finite state machine.
##
## Manages a set of [BaseState] child nodes and drives transitions between them.
## Add [BaseState] nodes as children in the scene tree, set [member initial_state],
## then call [method start] from the owner's [method Node._ready].
##
## [b]Usage:[/b] Create a concrete subclass for each state machine. The subclass holds
## typed [code]@onready[/code] references to each child state and exposes named transition
## methods. This avoids raw [StringName] literals scattered across state files and gives
## each state typed access to its siblings.
##
## [codeblock]
## class_name InventoryStateMachine
## extends StateMachine
##
## @onready var browse: BrowseState = $BrowseState
## @onready var action_menu: ActionMenuState = $ActionMenuState
##
## func go_to_browse() -> void:
##     transition_to(&"BrowseState")
## [/codeblock]
##
## Each [BaseState] subclass then casts [member BaseState.state_machine] to the concrete type
## to call the named transition methods and access sibling state references:
##
## [codeblock]
## @onready var _sm: InventoryStateMachine = state_machine as InventoryStateMachine
##
## func _on_confirm() -> void:
##     _sm.go_to_browse()
## [/codeblock]

## The initial state entered when [method start] is called. Must be a direct child of this node.
@export var initial_state: BaseState

## The currently active state. Read-only — use [method transition_to] or [method start] to change
## it.
var current_state: BaseState:
	get:
		return _current_state

## Backing dictionary populated in [method Node._ready], keyed by [StringName] node name.
var _states: Dictionary[StringName, BaseState] = {}
## Backing store for the [member current_state] read-only property.
var _current_state: BaseState = null
## Write-once — only the false → true transition is allowed.
## Set by [method start] the first time processing is enabled.
## Guards [method start] against being called more than once.
##
## Convention: every write-once guard added to this class must follow this
## same setter pattern.
var _started: bool = false:
	set(value):
		(
			Utils
			. require(
				not _started and value,
				"StateMachine._started: write-once — can only transition from false to true",
			)
		)
		_started = value


## Validates [member initial_state], builds the [member _states] lookup from child nodes,
## and disables processing until [method start] is called.
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
		_states[c.name] = c as BaseState

	(
		Utils
		. require(
			_states.has(initial_state.name),
			"StateMachine._ready: initial_state must be a direct child of this node",
		)
	)

	# No null-check needed — initial_state was already verified to be a BaseState above.
	_current_state = initial_state

	# Disable processing until start() is called by the owner's _ready().
	set_physics_process(false)
	set_process_unhandled_key_input(false)


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


## Transitions from the current state to the state named [param target_state_name].
## Calls [method BaseState.exit] on the outgoing state and [method BaseState.enter]
## on the incoming state, passing the previous state name automatically.
## Crashes if [param target_state_name] is the current state — self-transitions are not allowed.
func transition_to(target_state_name: StringName) -> void:
	(
		Utils
		. require(
			_states.has(target_state_name),
			"StateMachine.transition_to: no state found for: '%s'" % target_state_name,
		)
	)
	(
		Utils
		. require(
			target_state_name != _current_state.name,
			"StateMachine.transition_to: already in state: '%s'" % target_state_name,
		)
	)

	var previous_state_name: StringName = _current_state.name
	var target_state: BaseState = _states[target_state_name]

	_current_state.exit()
	_current_state = target_state
	_current_state.enter(previous_state_name)


## Returns [code]true[/code] when the machine is not already in [member initial_state].
## Check this before calling [method reset].
func can_reset() -> bool:
	return _current_state != initial_state


## Resets to [member initial_state] by calling [method transition_to].
## Crashes if already at [member initial_state] — call [method can_reset] first.
func reset() -> void:
	Utils.require(can_reset(), "StateMachine.reset: already at initial_state")
	transition_to(initial_state.name)


## Enables processing and enters [member initial_state].
## An empty [StringName] is passed as the previous state to signal initial entry.
##
## Must be called exactly once from the owner's [method Node._ready].
## Crashes if called before [method Node._ready] or a second time.
func start() -> void:
	(
		Utils
		. require(
			_current_state != null,
			"StateMachine.start: called before _ready() — call start() from the owner's _ready()",
		)
	)
	_started = true

	set_physics_process(true)
	set_process_unhandled_key_input(true)

	_current_state.enter(&"")
