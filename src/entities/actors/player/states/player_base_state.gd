class_name PlayerBaseState
extends BaseState
## Shared base for all [PlayerStateMachine] states.
##
## Provides a typed [member _sm] reference so each concrete state does not
## need to repeat the cast from [member BaseState.state_machine].
## Filters [method handle_input] to left/right actions only, then delegates to
## [method _on_player_input] — concrete states override that instead of [method handle_input].
##
## Facing direction is derived from [member AnimatedSprite2D.flip_h] on the body sprite:
## [code]false[/code] = right, [code]true[/code] = left.

@warning_ignore("unused_private_class_variable")
@onready var _sm: PlayerStateMachine = state_machine as PlayerStateMachine


## Resolves which state to transition to based on movement input.
##
## Priority: idle → turn → walk.
## Call from [method _on_player_input] in any state that reacts to movement input.
func _resolve_transition() -> void:
	var input_x: int = int(Input.get_axis(InputActions.LEFT, InputActions.RIGHT))
	if input_x == 0:
		_sm.go_to_idle()
	elif (input_x > 0) == _sm.player.body.flip_h:
		_sm.go_to_turn()
	else:
		_sm.go_to_walk()
