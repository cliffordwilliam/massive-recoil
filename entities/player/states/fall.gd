class_name PlayerFallState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.play("to_fall")
	owner.velocity.y = 0.0


func process_physics(delta: float) -> void:
	owner.velocity.x = Input.get_axis("left", "right") * (
		owner.WALK_SPEED if Input.is_action_pressed("walk") else owner.RUN_SPEED
	)
	owner.velocity.y += delta * owner.FALL_GRAVITY
	owner.velocity.y = min(owner.velocity.y, owner.MAX_FALL_SPEED)
	owner.move_and_slide()
	if owner.is_on_floor():
		try_grounded_transition("PlayerFallState")
