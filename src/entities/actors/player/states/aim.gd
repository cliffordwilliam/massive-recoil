# State where the player aims.
# the aim animation here is a function of angle and this state handles shoot and reload input.
class_name PlayerAimState
extends PlayerState

const POST_RELOAD_AIM_ANGLE: float = 0.6

var dest_angle: float = 0.0
var real_angle: float = 0.0:
	set(value):
		real_angle = value
		if player:
			player.body.frame = clampi(
				int(remap(real_angle, PI / 2.0, -PI / 2.0, 0, player.aim_frames - 1)),
				0,
				player.aim_frames - 1,
			)
			player.ray.rotation = PI - real_angle if player.body.flip_h else real_angle

@onready var fire_timer: Timer = $FireTimer


func enter(previous_state: StringName) -> void:
	player.body.play("aim") # Resets frame to 0.
	player.velocity.x = 0.0
	player.body.pause() # Frame is a function of angle, not time.
	# Use angle to update frame via setter.
	dest_angle = POST_RELOAD_AIM_ANGLE if previous_state == &"PlayerReloadState" else 0.0
	real_angle = POST_RELOAD_AIM_ANGLE if previous_state == &"PlayerReloadState" else 0.0
	player.ray.is_active = true


func exit() -> void:
	player.body.play() # Let frame be function of time again.
	player.ray.is_active = false
	fire_timer.stop()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if _try_fire():
			get_viewport().set_input_as_handled()

	elif event.is_action_pressed("reload"):
		if GameState.equipped_weapon_can_reload():
			state_machine.transition_to(&"PlayerReloadState", name)
			get_viewport().set_input_as_handled()


func physics_update(delta: float) -> void:
	if not Input.is_action_pressed("aim"):
		if try_exit():
			return

	# move_and_slide() is intentionally not called here.
	# This game has no gravity and no jumping. All floors use a constant snapping force
	# (floor_snap_length) to keep the player grounded on slopes at all times.
	# Velocity is zeroed out on aim entry, so there is no movement to process.

	# The player controls the destination angle; the real angle chases that destination.
	dest_angle += Input.get_axis("up", "down") * Player.AIM_SPEED * delta
	dest_angle = clampf(dest_angle, -PI / 2.0, PI / 2.0)
	real_angle = lerp(real_angle, dest_angle, 1.0 - pow(Player.AIM_SMOOTH, delta))


func _try_fire() -> bool:
	if fire_timer.time_left > 0.0:
		return false

	# If shot is fired (there is ammo), do recoil.
	if player.ray.shoot():
		dest_angle -= GameState.get_equipped_weapon_recoil_kick()
		dest_angle = clampf(dest_angle, -PI / 2.0, PI / 2.0)

		fire_timer.start(GameState.get_equipped_weapon_fire_rate())
		return true
	return false


func _on_fire_timer_timeout() -> void: # Connected via engine GUI
	if not GameState.get_equipped_weapon_is_automatic():
		return

	if Input.is_action_pressed("shoot"):
		_try_fire()
