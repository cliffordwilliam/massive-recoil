# Hold common player state logics
class_name PlayerState
extends BaseState

# Safe: owner is set during _enter_tree (before _ready), so this resolves correctly
@onready var player: Player = owner


# The priority order (aim > walk_back > idle > turn > run > walk)
func try_exit() -> bool:
	var new_state_name: StringName

	if Input.is_action_pressed("aim"):
		new_state_name = &"PlayerAimState"

	elif Input.is_action_pressed("down"):
		new_state_name = &"PlayerWalkBackState"

	elif is_zero_approx(Input.get_axis("left", "right")):
		new_state_name = &"PlayerIdleState"

	elif (Input.get_axis("left", "right") > 0) == player.body.flip_h:
		new_state_name = &"PlayerTurnState"

	elif Input.is_action_pressed("run"):
		new_state_name = &"PlayerRunState"

	else:
		new_state_name = &"PlayerWalkState"

	if new_state_name != name:
		state_machine.transition_to(new_state_name, name)

	return new_state_name != name
