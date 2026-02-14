class_name PlayerCrouchState
extends State

func enter(_prev_state: String) -> void:
	owner.animated_sprite.play("to_crouch")

func process_physics(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		return
	if not Input.is_action_pressed("ui_down"):
		if not Input.get_axis("ui_left", "ui_right"):
			return parent_node.transition_to("PlayerIdleState")
		if Input.get_axis("ui_left", "ui_right"):
			return parent_node.transition_to("PlayerRunState")
