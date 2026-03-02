class_name PlayerIdleState
extends PlayerState


func enter(old_state: Script) -> void:
	player.body.play("stop" if old_state == PlayerRunState else "idle")
	player.velocity.x = 0.0


func process_physics(_delta: float) -> void:
	try_exit(PlayerIdleState)
