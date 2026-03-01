class_name PlayerReloadState
extends PlayerState

const DEST_RELOAD_AIM_FRAME: float = 5.0

var current_aim_frame: float = 0.0

@onready var reload_timer: Timer = $ReloadTimer


func enter(_old: String) -> void:
	current_aim_frame = float(owner.body.frame)
	owner.velocity.x = 0.0
	reload_timer.wait_time = GameState.get_equipped_weapon_reload_speed()
	reload_timer.timeout.connect(_on_reload_timer_timeout)


func process_physics(delta: float) -> void:
	current_aim_frame = move_toward(current_aim_frame, DEST_RELOAD_AIM_FRAME, 20.0 * delta)
	owner.body.frame = int(current_aim_frame)
	if owner.body.frame == int(DEST_RELOAD_AIM_FRAME):
		get_parent().set_physics_process(false)
		owner.body.play("reload")
		reload_timer.start()


func exit() -> void:
	get_parent().set_physics_process(true)
	reload_timer.timeout.disconnect(_on_reload_timer_timeout)
	GameState.reload_equipped_weapon()


func _on_reload_timer_timeout() -> void:
	try_exit("PlayerReloadState")
