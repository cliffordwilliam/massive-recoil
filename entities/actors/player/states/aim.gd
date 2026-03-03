# State where player aims, aim animation here is a function of angle, handle shoot and reload input
class_name PlayerAimState
extends PlayerState

const POST_RELOAD_AIM_ANGLE: float = 0.6
const RECOIL_KICK: float = 0.1 # TODO: Maybe move recoil kick as a weapon prop?

var dest_angle: float = 0.0
var real_angle: float = 0.0:
	set(value):
		real_angle = value
		if player:
			player.body.frame = int(
				remap(real_angle, PI / 2.0, -PI / 2.0, 0, player.aim_frames - 1),
			)
			player.ray.rotation = PI - real_angle if player.body.flip_h else real_angle


func enter(previous_state: StringName) -> void:
	player.body.animation = "aim" # This sets frame index to 0
	player.velocity.x = 0.0
	player.body.pause() # Here frame is a function of angle
	dest_angle = 0.0
	real_angle = POST_RELOAD_AIM_ANGLE if previous_state == &"PlayerReloadState" else 0.0
	player.ray.is_active = true


func exit() -> void:
	player.body.play() # Let frame be function of time again
	player.ray.is_active = false


func handle_input(event: InputEvent) -> void:
	# TODO: Add a timer node to this to support weapon automatic fire rate feature
	if event.is_action_pressed("shoot"):
		# If shot is fired (there is ammo), do recoil
		if player.ray.shoot():
			dest_angle -= RECOIL_KICK
			dest_angle = clampf(dest_angle, -PI / 2.0, PI / 2.0)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("reload"):
		if GameState.equipped_weapon_can_reload():
			state_machine.transition_to(&"PlayerReloadState", name)
			get_viewport().set_input_as_handled()


func physics_update(delta: float) -> void:
	if not Input.is_action_pressed("aim"):
		if try_exit():
			return

	# Player control destination, real angle chases the destination
	dest_angle += Input.get_axis("up", "down") * Player.AIM_SPEED * delta
	dest_angle = clampf(dest_angle, -PI / 2.0, PI / 2.0)
	real_angle = lerp(real_angle, dest_angle, 1.0 - pow(Player.AIM_SMOOTH, delta))
