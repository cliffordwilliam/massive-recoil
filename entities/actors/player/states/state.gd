class_name PlayerState
extends State


func try_grounded_transition(current: String) -> bool:
	var next: String = ""
	if Input.is_action_pressed("aim"):
		next = "PlayerAimState"
	elif not Input.get_axis("left", "right"):
		next = "PlayerIdleState"
	elif (Input.get_axis("left", "right") > 0) != not owner.body.flip_h:
		next = "PlayerTurnState"
	elif Input.is_action_pressed("run"):
		next = "PlayerRunState"
	else:
		next = "PlayerWalkState"
	if next != current:
		get_parent().transition_to(next, current)
	return next != current
