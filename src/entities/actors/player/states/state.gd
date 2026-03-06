# Shared logic for all player states, including the priority‑ordered method try_exit transition.
class_name PlayerState
extends BaseState

# List down all my state names
const AIM: StringName = &"PlayerAimState"
const IDLE: StringName = &"PlayerIdleState"
const RELOAD: StringName = &"PlayerReloadState"
const RUN: StringName = &"PlayerRunState"
const TURN: StringName = &"PlayerTurnState"
const WALK: StringName = &"PlayerWalkState"
const WALK_BACK: StringName = &"PlayerWalkBackState"

# Safe: owner is set during _enter_tree (before _ready), so this resolves correctly.
@onready var player: Player = owner


# The priority order (aim > walk_back > idle > turn > run > walk)
# Contract: only call this from physics_update() (polling context).
# Input.is_action_pressed() and Input.get_axis() are safe there.
# Do NOT call this from handle_input() (event-driven context).
func try_exit() -> bool:
	var new_state_name: StringName

	if Input.is_action_pressed("aim") and GameState.get_equipped_weapon_id():
		new_state_name = AIM

	elif Input.is_action_pressed("down"):
		new_state_name = WALK_BACK

	elif is_zero_approx(Input.get_axis("left", "right")):
		new_state_name = IDLE

	elif (Input.get_axis("left", "right") > 0) == player.body.flip_h:
		new_state_name = TURN

	elif Input.is_action_pressed("run"):
		new_state_name = RUN

	else:
		new_state_name = WALK

	if new_state_name != name:
		state_machine.transition_to(new_state_name, name)

	return new_state_name != name
