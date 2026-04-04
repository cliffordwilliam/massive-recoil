class_name InventoryBaseState
extends BaseState
## Shared base for all [InventoryStateMachine] states.
##
## Provides a typed [member _sm] reference so each concrete state does not
## need to repeat the cast from [member BaseState.state_machine].

@warning_ignore("unused_private_class_variable")
@onready var _sm: InventoryStateMachine = state_machine as InventoryStateMachine
