class_name PlayerJumpState
extends State


func enter(_prev_state: StringName) -> void:
	owner.body.play("up")
	owner.velocity.y -= owner.JUMP_SPEED


func process_physics(delta: float) -> void:
	owner.velocity.x = Input.get_axis("left", "right") * (
		owner.WALK_SPEED if Input.is_action_pressed("walk") else owner.RUN_SPEED
	)
	owner.velocity.y += delta * (
		owner.NORMAL_GRAVITY if Input.is_action_pressed("jump") else owner.FALL_GRAVITY
	)
	owner.velocity.y = min(owner.velocity.y, owner.MAX_FALL_SPEED)
	owner.move_and_slide()
	if not owner.velocity.y < 0.0:
		parent_node.transition_to("PlayerFallState")
