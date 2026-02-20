class_name PlayerAimState
extends PlayerState

var aim_angle: float = 0.0:
	set(value):
		aim_angle = clampf(value, -PI / 2.0, PI / 2.0)
		var total_frames: int = owner.body.sprite_frames.get_frame_count("aim")
		owner.body.frame = int(remap(aim_angle, PI / 2.0, -PI / 2.0, 0, total_frames - 1))


func enter(_prev_state: StringName) -> void:
	owner.body.animation = "aim"
	owner.velocity.x = 0.0
	aim_angle = 0.0


func process_physics(delta: float) -> void:
	if not Input.is_action_pressed("aim"):
		if try_grounded_transition("PlayerAimState"):
			return
	var input_dir: float = Input.get_axis("up", "down")
	aim_angle = clampf(aim_angle + input_dir * owner.AIM_SPEED * delta, -PI / 2.0, PI / 2.0)
