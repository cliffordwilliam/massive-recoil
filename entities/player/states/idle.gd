class_name PlayerIdleState
extends State

func enter(prev_state: String) -> void:
	if prev_state == "PlayerRunState":
		owner.animated_sprite.play("stop")
	elif prev_state == "PlayerCrouchState":
		owner.animated_sprite.play("crouch_to_idle")
	elif prev_state == "PlayerFallState":
		owner.animated_sprite.play("land")
	else:
		owner.animated_sprite.play("idle")
	owner.velocity.x = 0.0

func process_physics(_delta: float) -> void:
	if Input.is_action_pressed("ui_down"):
		return parent_node.transition_to("PlayerCrouchState")
	if Input.is_action_just_pressed("ui_up"):
		return parent_node.transition_to("PlayerJumpState")
	if Input.get_axis("ui_left", "ui_right") and Input.is_action_pressed("ui_accept"):
		return parent_node.transition_to("PlayerWalkState")
	if Input.get_axis("ui_left", "ui_right"):
		return parent_node.transition_to("PlayerRunState")
