class_name PlayerState
extends State

func try_grounded_transition(current: String) -> bool:
	var next: String = resolve_grounded_transition()
	if next != current:
		parent_node.transition_to(next)
		return true
	return false


func resolve_grounded_transition() -> String:
	if Input.is_action_pressed("crouch"):
		return "PlayerCrouchState"
	if Input.is_action_just_pressed("jump"):
		return "PlayerJumpState"
	if not Input.get_axis("left", "right"):
		return "PlayerIdleState"
	if Input.get_axis("left", "right") and Input.is_action_pressed("walk"):
		return "PlayerWalkState"
	if Input.get_axis("left", "right"):
		return "PlayerRunState"
	return ""
