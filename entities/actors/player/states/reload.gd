class_name PlayerReloadState
extends PlayerState

const DEST_RELOAD_AIM_FRAME: float = 5.0

var current_aim_frame: float = 0.0
var reload_completed: bool = false

@onready var reload_timer: Timer = $ReloadTimer


func enter(_old: String) -> void:
	current_aim_frame = float(owner.body.frame)
	reload_completed = false
	owner.velocity.x = 0.0
	reload_timer.wait_time = GameState.get_equipped_weapon_reload_speed()


func process_physics(delta: float) -> void:
	if owner.body.animation == "reload":
		return
	current_aim_frame = move_toward(current_aim_frame, DEST_RELOAD_AIM_FRAME, 20.0 * delta)
	owner.body.frame = int(current_aim_frame)
	if owner.body.frame == int(DEST_RELOAD_AIM_FRAME) and reload_timer.is_stopped():
		owner.body.play("reload")
		reload_timer.start()


func exit() -> void:
	reload_timer.stop()
	if reload_completed:
		GameState.reload_weapon_by_id(GameState.get_equipped_weapon_id())


func _on_reload_timer_timeout() -> void: # Connected via engine GUI
	reload_completed = true
	try_exit("PlayerReloadState")
