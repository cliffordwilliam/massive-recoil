class_name PlayerAimState
extends PlayerState

const POST_RELOAD_AIM_ANGLE: float = 0.6
const RECOIL_KICK: float = 0.1 # TODO: Maybe move recoil kick as a weapon prop?

var dest_angle: float = 0.0
var real_angle: float: # Setter skipped at init — player is null until _ready
	set(value):
		real_angle = value
		if player:
			player.body.frame = int(remap(real_angle, PI / 2.0, -PI / 2.0, 0, player.aim_frames - 1))
			player.ray.rotation = PI - real_angle if player.body.flip_h else real_angle


func enter(old_state: Script) -> void:
	player.body.animation = "aim" # This sets frame index to 0
	player.velocity.x = 0.0
	player.body.pause() # Here frame is a function of angle
	dest_angle = 0.0
	real_angle = POST_RELOAD_AIM_ANGLE if old_state == PlayerReloadState else 0.0
	player.ray.set_active(true)


func exit() -> void:
	player.body.play() # Let frame be function of time again
	player.ray.set_active(false)


func process_physics(delta: float) -> void:
	if not Input.is_action_pressed("aim"):
		if try_exit(PlayerAimState):
			return
	dest_angle += Input.get_axis("up", "down") * player.AIM_SPEED * delta
	dest_angle = clampf(dest_angle, -PI / 2.0, PI / 2.0)
	real_angle = lerp(real_angle, dest_angle, 1.0 - pow(player.AIM_SMOOTH, delta))
	# TODO: Add a timer node to this to support weapon automatic fire rate feature
	if Input.is_action_just_pressed("shoot"):
		dest_angle -= RECOIL_KICK
		player.ray.shoot()
	elif Input.is_action_just_pressed("reload"):
		if GameState.equipped_weapon_can_reload():
			state_machine.exit_to(PlayerReloadState, PlayerAimState)
