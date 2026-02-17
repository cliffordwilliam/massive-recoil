class_name PlayerCrouchState
extends State

func enter(_prev_state: String) -> void:
	owner.animated_sprite.play("to_crouch")
	owner.velocity.x = 0.0


func process_physics(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		return parent_node.transition_to("PlayerJumpState")
	if not Input.is_action_pressed("ui_down"):
		if not Input.get_axis("ui_left", "ui_right"):
			return parent_node.transition_to("PlayerIdleState")
		if Input.get_axis("ui_left", "ui_right") and Input.is_action_pressed("ui_accept"):
			return parent_node.transition_to("PlayerWalkState")
		if Input.get_axis("ui_left", "ui_right"):
			return parent_node.transition_to("PlayerRunState")
