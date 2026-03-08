# State where the player aims.
# the aim animation here is a function of angle and this state handles shoot and reload input.
class_name PlayerAimState
extends PlayerState

const POST_RELOAD_AIM_ANGLE: float = 0.6

var dest_angle: float = 0.0

var real_angle: float = 0.0:
	set(value):
		real_angle = value
		# player is an @onready variable, assigned during _ready().
		# This guard is safe because no ancestor sets real_angle before this node's
		# _ready() fires — @onready assignment happens as part of the _ready() notification,
		# after all children are ready. If real_angle is set before _ready() the setter
		# silently no-ops and the angle is re-applied on the first physics_update() tick.
		# Doc reference: docs/godot/tutorials/scripting/gdscript/gdscript_basics.rst — @onready
		# annotation.
		if player:
			# set_frame_and_progress() avoids the side effect of resetting frame_progress
			# that occurs when assigning frame directly.
			# Doc ref: docs/godot/classes/class_animatedsprite2d.rst — frame property.
			player.body.set_frame_and_progress(
				clampi(
					int(remap(real_angle, PI / 2.0, -PI / 2.0, 0, player.aim_frames - 1)),
					0,
					player.aim_frames - 1,
				),
				0.0,
			)
			player.ray.rotation = PI - real_angle if player.body.is_flipped_h() else real_angle

@onready var fire_timer: Timer = $FireTimer


func _ready() -> void:
	# Fire rate is a gameplay mechanic that must be deterministic across frame rates.
	# TIMER_PROCESS_IDLE ties resolution to render FPS — must be set to PHYSICS in the inspector.
	# Catch misconfiguration at startup rather than silently using the wrong callback.
	# Doc reference: docs/godot/classes/class_timer.rst — process_callback property
	Utils.require(
		fire_timer.process_callback == Timer.TIMER_PROCESS_PHYSICS,
		"PlayerAimState: FireTimer.process_callback must be TIMER_PROCESS_PHYSICS set in inspector",
	)


func enter(previous_state: StringName) -> void:
	player.body.play("aim") # Resets frame to 0.
	player.velocity.x = 0.0
	player.body.pause() # Frame is a function of angle, not time.
	# Use angle to update frame via setter.
	dest_angle = 0.0
	real_angle = POST_RELOAD_AIM_ANGLE if previous_state == RELOAD else 0.0
	player.ray.is_active = true


func exit() -> void:
	# Let frame be function of time again.
	# Here no need to call player.body.play(), that line is unnecessary,
	# Every incoming state already calls player.body.play("their_animation") in its own enter()
	player.ray.is_active = false
	fire_timer.stop()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if _try_fire():
			get_viewport().set_input_as_handled()

	elif event.is_action_pressed("reload"):
		if GameState.equipped_weapon_can_reload():
			state_machine.transition_to(RELOAD, name)
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
	# AIM_SMOOTH is a geometric-decay base: fraction of angular distance remaining per second.
	# pow(AIM_SMOOTH, delta) == exp(ln(AIM_SMOOTH) * delta), equivalent to the framerate-independent
	# weight formula 1 - exp(-speed * delta) from the interpolation tutorial.
	# Doc ref: docs/godot/tutorials/math/interpolation.rst
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


func _on_fire_timer_timeout() -> void: # Connected via engine GUI.
	if not GameState.get_equipped_weapon_is_automatic():
		return

	if Input.is_action_pressed("shoot"):
		_try_fire()
