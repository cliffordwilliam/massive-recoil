class_name PlayerIdleState
extends PlayerState


func enter(prev_state: String) -> void:
	owner.body.play("stop" if prev_state == "PlayerRunState" else "idle")
	owner.velocity.x = 0.0


func process_physics(_delta: float) -> void:
	try_exit("PlayerIdleState")
