# State where the player is reloading.
# The aim angle must travel to the reload angle first before playing the reload animation.
# The reload animation is just something to look at while the reload timer counts down.
# Reload is only granted when the reload timer is over; if it ends early then nothing happens.
# This is intentional design:
# the player is fully committed to the reload duration with no way to cancel.
class_name PlayerReloadState
extends PlayerState

const DEST_RELOAD_AIM_FRAME: float = 5.0
const FRAME_TRANSITION_SPEED: float = 20.0

var tween: Tween
var equipped_weapon_reload_speed: float = 0.0

@onready var reload_timer: Timer = $ReloadTimer


func _ready() -> void:
	# Reload duration must be deterministic across frame rates.
	# TIMER_PROCESS_IDLE ties resolution to render FPS — must be set to PHYSICS in the inspector.
	# Catch misconfiguration at startup rather than silently using the wrong callback.
	# Doc reference: docs/godot/classes/class_timer.rst — process_callback property
	Utils.require(
		reload_timer.process_callback == Timer.TIMER_PROCESS_PHYSICS,
		"PlayerReloadState: ReloadTimer.process_callback must be TIMER_PROCESS_PHYSICS set in inspector",
	)


func _exit_tree() -> void:
	tween = Utils.kill_tween(tween)


func enter(_old_state: StringName) -> void:
	player.velocity.x = 0.0
	equipped_weapon_reload_speed = GameState.get_equipped_weapon_reload_speed()

	var start_frame: float = float(player.body.frame)
	var duration: float = abs(DEST_RELOAD_AIM_FRAME - start_frame) / FRAME_TRANSITION_SPEED

	# Play the reload animation if the starting aim angle is close to the reload aim destination.
	if duration <= 0.0:
		_start_reload_animation()
		return

	# Otherwise, spend time traveling to the reload angle first, then play the reload animation.
	tween = Utils.kill_tween(tween)
	tween = create_tween()
	tween.tween_method(_set_aim_frame, start_frame, DEST_RELOAD_AIM_FRAME, duration)
	tween.tween_callback(_start_reload_animation)


func exit() -> void:
	tween = Utils.kill_tween(tween)
	reload_timer.stop()


func _set_aim_frame(value: float) -> void:
	# set_frame_and_progress() avoids the side effect of resetting frame_progress
	# that occurs when assigning frame directly.
	# Doc ref: docs/godot/classes/class_animatedsprite2d.rst — frame property.
	player.body.set_frame_and_progress(
		clampi(int(value), 0, player.aim_frames - 1),
		0.0,
	)


# Plays when the aim angle reaches the reload aim destination angle.
func _start_reload_animation() -> void:
	# If there is wait time, start timer and play the reload animation.
	if equipped_weapon_reload_speed > 0.0:
		player.body.play("reload")
		reload_timer.wait_time = equipped_weapon_reload_speed
		reload_timer.start()

	# If there is no wait time, then just reload now and exit.
	else:
		GameState.reload_weapon_by_id(GameState.get_equipped_weapon_id())
		try_exit()


# Reload is only ever successful when the reload timer runs out.
func _on_reload_timer_timeout() -> void: # Connected via engine GUI.
	GameState.reload_weapon_by_id(GameState.get_equipped_weapon_id())
	try_exit()
