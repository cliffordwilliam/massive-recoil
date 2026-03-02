class_name PlayerState
extends BaseState


func try_exit(old_state: String) -> bool:
	var new_state: String = ""
	if Input.is_action_pressed("aim"):
		new_state = "PlayerAimState"
	elif Input.is_action_pressed("down"):
		new_state = "PlayerWalkBackState"
	elif is_zero_approx(Input.get_axis("left", "right")):
		new_state = "PlayerIdleState"
	elif (Input.get_axis("left", "right") > 0) == owner.body.flip_h:
		new_state = "PlayerTurnState"
	elif Input.is_action_pressed("run"):
		new_state = "PlayerRunState"
	else:
		new_state = "PlayerWalkState"
	if new_state != old_state:
		get_parent().exit_to(new_state, old_state)
	return new_state != old_state
