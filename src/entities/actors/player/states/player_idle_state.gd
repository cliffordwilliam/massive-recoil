class_name PlayerIdleState
extends PlayerBaseState
## Idle state for [PlayerStateMachine].
##
## Default state. Zeroes horizontal velocity and plays the idle animation on entry.
## Exits to [PlayerTurnState] or [PlayerWalkState] when movement input is detected.


func enter(_old_state: BaseState) -> void:
	_sm.player.velocity.x = 0.0
	_sm.player.body.play(&"idle")


func physics_update(_delta: float) -> void:
	_resolve_transition()
