class_name PlayerFallState
extends State

func enter(_prev_state: String) -> void:
	owner.animated_sprite.play("to_fall")

func process_physics(delta: float) -> void:
	owner.velocity.x = Input.get_axis("ui_left", "ui_right") * (
		owner.WALK_SPEED if Input.is_action_pressed("ui_accept") else owner.RUN_SPEED
	)
	owner.velocity.y += delta * owner.FALL_GRAVITY
	owner.velocity.y = min(owner.velocity.y, owner.MAX_FALL_SPEED)
	owner.move_and_slide()

	if owner.is_on_floor():
		if Input.is_action_pressed("ui_down"):
			return parent_node.transition_to("PlayerCrouchState")
		if Input.is_action_just_pressed("ui_up"):
			return parent_node.transition_to("PlayerJumpState")
		if not Input.get_axis("ui_left", "ui_right"):
			return parent_node.transition_to("PlayerIdleState")
		if Input.get_axis("ui_left", "ui_right") and Input.is_action_pressed("ui_accept"):
			return parent_node.transition_to("PlayerWalkState")
		if Input.get_axis("ui_left", "ui_right"):
			return parent_node.transition_to("PlayerRunState")
