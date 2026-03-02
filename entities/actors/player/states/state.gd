class_name PlayerState
extends BaseState

# Safe: owner is set during _enter_tree (before _ready), so this resolves correctly
@onready var player: Player = owner


func try_exit(old_state: Script) -> bool:
	var new_state: Script
	if Input.is_action_pressed("aim"):
		new_state = PlayerAimState
	elif Input.is_action_pressed("down"):
		new_state = PlayerWalkBackState
	elif is_zero_approx(Input.get_axis("left", "right")):
		new_state = PlayerIdleState
	elif (Input.get_axis("left", "right") > 0) == player.body.flip_h:
		new_state = PlayerTurnState
	elif Input.is_action_pressed("run"):
		new_state = PlayerRunState
	else:
		new_state = PlayerWalkState
	if new_state != old_state:
		state_machine.exit_to(new_state, old_state)
	return new_state != old_state
