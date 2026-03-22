class_name BaseState
extends Node
## Abstract base class for all states managed by [StateMachine].
##
## Extend this class for each concrete state and override [method enter], [method exit],
## [method handle_input], and [method physics_update] as needed.
## Do not override [method Node._unhandled_key_input] — override [method handle_input]
## instead to avoid double-processing input that [StateMachine] already dispatches here.

## The parent [StateMachine] that owns this state.
## Cast to the concrete subclass in [method Node._ready] to access typed sibling references.
# Children are readied before parents, but get_parent() is valid at _ready time.
@onready var state_machine: StateMachine = get_parent() as StateMachine


func _ready() -> void:
	Utils.require(state_machine is StateMachine, "BaseState._ready: parent must be a StateMachine")


## Called when this state becomes active.
## [param _old_state] is the name of the previous state, or an empty [StringName] on initial entry.
func enter(_old_state: StringName) -> void:
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
