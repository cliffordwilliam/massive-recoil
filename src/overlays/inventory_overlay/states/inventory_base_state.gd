class_name InventoryBaseState
extends BaseState
## Shared base for all [InventoryStateMachine] states.
##
## Provides a typed [member _sm] reference so each concrete state does not
## need to repeat the cast from [member BaseState.state_machine].

## Typed reference to the parent [InventoryStateMachine].
@onready var _sm: InventoryStateMachine = state_machine as InventoryStateMachine


## Calls [method BaseState._ready], then asserts the parent machine is an [InventoryStateMachine].
func _ready() -> void:
	super()
	(
		Utils
		. require(
			_sm is InventoryStateMachine,
			"InventoryBaseState._ready: parent state machine must be an InventoryStateMachine",
		)
	)
