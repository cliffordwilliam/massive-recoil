class_name PlayerWalkState
extends PlayerBaseState
## Walk state for [PlayerStateMachine].
##
## Sets horizontal velocity to [constant Player.WALK_SPEED] in the current facing
## direction and plays the walk animation on entry.
## Exits to [PlayerIdleState] when input stops or the player reverses direction.


func enter(_old_state: BaseState) -> void:
	_sm.player.velocity.x = (-1.0 if _sm.player.body.flip_h else 1.0) * Player.WALK_SPEED
	_sm.player.body.play(&"walk")


func physics_update(_delta: float) -> void:
	_sm.player.move_and_slide()
	_resolve_transition()
