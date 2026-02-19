class_name PlayerState
extends State


func try_grounded_transition(current: String) -> bool:
	var next: String = ""
	if Input.is_action_pressed("aim") and owner.arms.sprite_frames != owner.ARMS:
		next = "PlayerAimState"
	elif Input.is_action_pressed("crouch"):
		next = "PlayerCrouchState"
	elif Input.is_action_just_pressed("jump"):
		next = "PlayerJumpState"
	elif not Input.get_axis("left", "right"):
		next = "PlayerIdleState"
	elif Input.get_axis("left", "right") and Input.is_action_pressed("walk"):
		next = "PlayerWalkState"
	elif Input.get_axis("left", "right"):
		next = "PlayerRunState"
	if next != current:
		parent_node.transition_to(next)
		return true
	return false
