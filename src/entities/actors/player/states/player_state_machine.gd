class_name PlayerStateMachine
extends StateMachine
## Concrete state machine for [Player].
##
## Holds shared movement state that persists across state transitions.
## Each player state extends [PlayerBaseState], which exposes a typed
## [member PlayerBaseState._sm] reference and named transition methods on this machine.

@onready var player: Player = get_parent() as Player
@onready var _idle: PlayerIdleState = $PlayerIdleState
@onready var _walk: PlayerWalkState = $PlayerWalkState
@onready var _turn: PlayerTurnState = $PlayerTurnState


func go_to_idle() -> void:
	if current_state == _idle:
		return
	transition_to(_idle)


func go_to_walk() -> void:
	if current_state == _walk:
		return
	transition_to(_walk)


func go_to_turn() -> void:
	transition_to(_turn)
