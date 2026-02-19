class_name PlayerAimState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.animation = "aim"
	owner.velocity.x = 0.0


func process_physics(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		return parent_node.transition_to("PlayerJumpState")
	if Input.is_action_just_pressed("crouch"):
		return parent_node.transition_to("PlayerCrouchState")
	if not Input.is_action_pressed("aim"):
		if try_grounded_transition("PlayerCrouchState"):
			return
	var local_mouse: Vector2 = owner.aim_pivot.get_local_mouse_position()
	owner.body.set_flip(local_mouse.x < 0.0)
	local_mouse.x *= -1 if owner.body.flip_h else 1
	var total_frames: int = owner.body.sprite_frames.get_frame_count("aim")
	owner.body.frame = int(remap(local_mouse.angle(), PI / 2.0, -PI / 2.0, 0, total_frames - 1))
