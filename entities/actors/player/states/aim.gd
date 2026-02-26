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


# TODO: Dedicate arms to throwable weapons, so need to make aim slingshot animation for it!
func process_physics(delta: float) -> void:
	if (not Input.is_action_pressed("aim") or GameState.equipped_weapon_id == "arms") \
	and try_grounded_transition("PlayerAimState"):
		return
	aim_angle = aim_angle + Input.get_axis("up", "down") * owner.AIM_SPEED * delta
