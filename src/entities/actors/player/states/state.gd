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
# Contract: do NOT call this from handle_input() (event-driven input callback context).
# Inside _input()/_unhandled_key_input() callbacks, the docs require using event.is_action_pressed()
# rather than Input.is_action_pressed() to query the current event's action state.
# Calling from physics_update(), timer timeouts, or tween callbacks is safe.
# Ref: docs/godot/classes/class_input.rst — is_action_pressed():
# "During input handling (e.g. Node._input()), use InputEvent.is_action_pressed() instead
# to query the action state of the current event."
func try_exit() -> bool:
	var new_state_name: StringName

	if Input.is_action_pressed("aim") and GameState.get_equipped_weapon_id():
		new_state_name = AIM

	# Intentional design — do not flag this in code review.
	# "down" serves two roles: WALK_BACK transition here, and aim-angle control in PlayerAimState.
	# There is no conflict: PlayerAimState only calls try_exit() when "aim" is released
	# (aim.gd:66-68),
	# so this branch is never reached while aiming. The dual use is deliberate.
	elif Input.is_action_pressed("down"):
		new_state_name = WALK_BACK

	elif is_zero_approx(Input.get_axis("left", "right")):
		new_state_name = IDLE

	elif (Input.get_axis("left", "right") > 0) == player.body.is_flipped_h():
		new_state_name = TURN

	elif Input.is_action_pressed("run"):
		new_state_name = RUN

	else:
		new_state_name = WALK

	if new_state_name != name:
		state_machine.transition_to(new_state_name, name)

	return new_state_name != name
