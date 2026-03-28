class_name BaseState
extends Node
## Abstract base class for all states managed by [StateMachine].
##
## Extend this class for each concrete state and override [method enter], [method exit],
## [method handle_input], and [method physics_update] as needed.
## Do not override [method Node._unhandled_key_input] — override [method handle_input]
## instead to avoid double-processing input that [StateMachine] already dispatches here.
##
## Naming convention: prefix the [code]class_name[/code] with the domain of the owning
## state machine to prevent conflicts — e.g. [code]InventoryBrowseState[/code] rather
## than [code]BrowseState[/code]. GDScript has no namespaces so unqualified names collide
## across domains. See [InventoryBaseState] for the established pattern.

## The parent [StateMachine] that owns this state.
## For typed access to the concrete machine and its sibling states, create an intermediate
## base class that performs the cast once — see [InventoryBaseState] for the pattern.
## Children are readied before parents, but get_parent() is valid at _ready time.
@onready var state_machine: StateMachine = get_parent() as StateMachine


## Validates that this state is a direct child of a [StateMachine].
func _ready() -> void:
	Utils.require(state_machine is StateMachine, "BaseState._ready: parent must be a StateMachine")


## Called when this state becomes active.
## [param _old_state] is the previous state, or [code]null[/code] on initial entry.
func enter(_old_state: BaseState) -> void:
	pass


## Called when this state is about to be replaced by another state.
func exit() -> void:
	pass


## Called by [StateMachine] for every unhandled key input event while this state is active.
## Override this instead of [method Node._unhandled_key_input] to avoid double-processing.
func handle_input(_event: InputEvent) -> void:
	pass


## Called every physics frame while this state is active.
func physics_update(_delta: float) -> void:
	pass


## Called when the owner requests a draw update while this state is active.
## Override to issue draw commands via the owner's [CanvasItem] methods.
func draw() -> void:
	pass
