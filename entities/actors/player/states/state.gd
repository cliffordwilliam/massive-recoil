class_name PlayerState
extends State


func try_exit(old: String) -> bool:
	var new: String = ""
	if Input.is_action_pressed("aim"):
		new = "PlayerAimState"
	elif Input.is_action_pressed("down"):
		new = "PlayerWalkBackState"
	elif is_zero_approx(Input.get_axis("left", "right")):
		new = "PlayerIdleState"
	elif (Input.get_axis("left", "right") > 0) == owner.body.flip_h:
		new = "PlayerTurnState"
	elif Input.is_action_pressed("run"):
		new = "PlayerRunState"
	else:
		new = "PlayerWalkState"
	if new != old:
		get_parent().exit_to(new, old)
	return new != old
