class_name PlayerAimState
extends PlayerState

var dest_angle: float = 0.0
var real_angle: float = 0.0:
	set(value):
		real_angle = value
		owner.body.frame = int(remap(real_angle, PI / 2.0, -PI / 2.0, 0, owner.aim_frames - 1))
		owner.ray.rotation = PI - real_angle if owner.body.flip_h else real_angle


func enter(prev_state: String) -> void:
	owner.body.animation = "aim"
	owner.body.pause() # Here frame is a func of angle
	dest_angle = 0.0
	real_angle = 0.6 if prev_state == "PlayerReloadState" else 0.0
	owner.velocity.x = 0.0
	owner.ray.set_active(true)


func exit() -> void:
	owner.body.play() # Let frame be func of time again
	owner.ray.set_active(false)


func process_physics(delta: float) -> void:
	if not Input.is_action_pressed("aim"):
		if try_grounded_exit("PlayerAimState"):
			return
	dest_angle += Input.get_axis("up", "down") * owner.AIM_SPEED * delta
	dest_angle = clampf(dest_angle, -PI / 2.0, PI / 2.0)
	real_angle = lerp(real_angle, dest_angle, 1.0 - pow(owner.AIM_SMOOTH, delta))
	if Input.is_action_just_pressed("shoot"):
		dest_angle -= 0.1 # TODO: Maybe move recoil kick as a weapon prop?
		owner.ray.shoot()
	elif Input.is_action_just_pressed("reload"):
		if GameState.equipped_weapon_can_reload():
			get_parent().transition_to("PlayerReloadState", "PlayerAimState")
