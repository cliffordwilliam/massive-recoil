class_name PlayerReloadState
extends PlayerState

const DEST_RELOAD_AIM_FRAME: float = 5.0
const FRAME_TRANSITION_SPEED: float = 20.0

var _reload_tween: Tween

@onready var reload_timer: Timer = $ReloadTimer


func enter(_old_state: Script) -> void:
	var start_frame: float = float(player.body.frame)
	player.velocity.x = 0.0
	reload_timer.wait_time = GameState.get_equipped_weapon_reload_speed()
	var duration: float = abs(DEST_RELOAD_AIM_FRAME - start_frame) / FRAME_TRANSITION_SPEED
	if duration <= 0.0:
		_start_reload_animation()
		return
	if _reload_tween:
		_reload_tween.kill()
	_reload_tween = create_tween()
	_reload_tween.tween_method(_set_aim_frame, start_frame, DEST_RELOAD_AIM_FRAME, duration)
	_reload_tween.tween_callback(_start_reload_animation)


func exit() -> void:
	if _reload_tween:
		_reload_tween.kill()
		_reload_tween = null
	reload_timer.stop()


func _set_aim_frame(value: float) -> void:
	player.body.frame = int(value)


func _start_reload_animation() -> void:
	player.body.play("reload")
	reload_timer.start()


func _on_reload_timer_timeout() -> void: # Connected via engine GUI
	GameState.reload_weapon_by_id(GameState.get_equipped_weapon_id())
	try_exit(PlayerReloadState)
