class_name PlayerIdleState
extends PlayerState


# State where player stands still
func enter(previous_state: StringName) -> void:
	player.body.play("stop" if previous_state == &"PlayerRunState" else "idle")
	player.velocity.x = 0.0


func physics_update(_delta: float) -> void:
	try_exit()
