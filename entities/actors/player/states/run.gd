# State where player runs forward
class_name PlayerRunState
extends PlayerState


func enter(_msg: Dictionary = { }) -> void:
	player.body.play("to_run")
	player.velocity.x = (-player.RUN_SPEED if player.body.flip_h else player.RUN_SPEED)


func physics_update(_delta: float) -> void:
	if not try_exit():
		player.move_and_slide()
