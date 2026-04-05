class_name PlayerTurnState
extends PlayerBaseState
## Turn state for [PlayerStateMachine].
##
## Flips the body sprite and plays the turn animation on entry.
## Polls each physics frame and exits to [PlayerIdleState] once the animation finishes.


func enter(_old_state: BaseState) -> void:
	_sm.player.velocity.x = 0.0
	_sm.player.body.flip_h = not _sm.player.body.flip_h
	_sm.player.body.play(&"turn")


func physics_update(_delta: float) -> void:
	if _sm.player.body.animation == &"turn":
		if not _sm.player.body.is_playing():
			_resolve_transition()
