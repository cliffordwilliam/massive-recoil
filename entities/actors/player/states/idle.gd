# State where player stands still
class_name PlayerIdleState
extends PlayerState


func enter(msg: Dictionary = { }) -> void:
	player.body.play("stop" if msg.get("previous") == &"PlayerRunState" else "idle")
	player.velocity.x = 0.0


func physics_update(_delta: float) -> void:
	try_exit()
