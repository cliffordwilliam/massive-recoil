class_name PlayerReloadState
extends PlayerState

var current_aim_frame: float = 0.0
var ready_to_reload: bool = false

@onready var reload_timer: Timer = $ReloadTimer


func enter(_prev_state: String) -> void:
	owner.body.animation = "aim"
	current_aim_frame = float(owner.body.frame)
	owner.velocity.x = 0.0
	reload_timer.wait_time = GameState.get_equipped_weapon_reload_speed()
	reload_timer.timeout.connect(_on_reload_timer_timeout)


func process_physics(delta: float) -> void:
	if ready_to_reload:
		return
	current_aim_frame = move_toward(current_aim_frame, 5.0, 20.0 * delta)
	owner.body.frame = int(current_aim_frame)
	if owner.body.frame == 5:
		ready_to_reload = true
		owner.body.play("reload")
		reload_timer.start()


func exit() -> void:
	current_aim_frame = 0.0
	ready_to_reload = false
	reload_timer.timeout.disconnect(_on_reload_timer_timeout)
	reload_timer.stop()
	GameState.reload_equipped_weapon()


func _on_reload_timer_timeout() -> void:
	try_grounded_exit("PlayerReloadState")
