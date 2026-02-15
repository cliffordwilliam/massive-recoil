class_name PlayerJumpState
extends State

func enter(_prev_state: String) -> void:
	owner.animated_sprite.play("up")
	owner.velocity.y -= owner.JUMP_SPEED

func process_physics(delta: float) -> void:
	owner.velocity.x = Input.get_axis("ui_left", "ui_right") * (
		owner.WALK_SPEED if Input.is_action_pressed("ui_accept") else owner.RUN_SPEED
	)
	owner.velocity.y += delta * (
		owner.NORMAL_GRAVITY if Input.is_action_pressed("ui_up") else owner.FALL_GRAVITY
	)
	owner.velocity.y = min(owner.velocity.y, owner.MAX_FALL_SPEED)
	owner.move_and_slide()

	if not owner.velocity.y < 0:
		return parent_node.transition_to("PlayerFallState")
