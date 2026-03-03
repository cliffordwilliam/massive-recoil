# State where player is reloading, must come from aim state
# Must travel from aim angle to reload angle first before playing reload animation
# Reload animation is just a thing to look at as the reload timer counts down
# Reload will only be granted only when the reload timer is over, if it ends early then nothing
# This is intentional design, player is fully committed to reload duration with no way to cancel
class_name PlayerReloadState
extends PlayerState

const DEST_RELOAD_AIM_FRAME: float = 5.0
const FRAME_TRANSITION_SPEED: float = 20.0

var reload_tween: Tween

@onready var reload_timer: Timer = $ReloadTimer


func _exit_tree() -> void:
	_kill_tween()


func enter(_old_state: StringName) -> void:
	player.velocity.x = 0.0
	reload_timer.wait_time = GameState.get_equipped_weapon_reload_speed()

	var start_frame: float = float(player.body.frame)
	var duration: float = abs(DEST_RELOAD_AIM_FRAME - start_frame) / FRAME_TRANSITION_SPEED

	# Play reload animation if start aim angle is close to reload aim angle destination
	if duration <= 0.0:
		_start_reload_animation()
		return

	# Otherwise spend time to travel to reload angle first, then play the reload animation
	if reload_tween:
		reload_tween.kill()

	reload_tween = create_tween()
	reload_tween.tween_method(_set_aim_frame, start_frame, DEST_RELOAD_AIM_FRAME, duration)
	reload_tween.tween_callback(_start_reload_animation)


func exit() -> void:
	_kill_tween()
	reload_timer.stop()


func _kill_tween() -> void:
	if reload_tween:
		reload_tween.kill()
		reload_tween = null


func _set_aim_frame(value: float) -> void:
	player.body.frame = int(value)


# Plays when the aim angle reaches the reload aim destination angle
func _start_reload_animation() -> void:
	player.body.play("reload")
	reload_timer.start()


# Reload is only ever successful when the reload timer runs out
func _on_reload_timer_timeout() -> void: # Connected via engine GUI
	GameState.reload_weapon_by_id(GameState.get_equipped_weapon_id())
	try_exit()
