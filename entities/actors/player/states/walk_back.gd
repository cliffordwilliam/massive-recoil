# State where player walks backward
class_name PlayerWalkBackState
extends PlayerState


func enter(_msg: Dictionary = { }) -> void:
	player.body.play_backwards("walk")
	player.velocity.x = (player.WALK_SPEED if player.body.flip_h else -player.WALK_SPEED)


func physics_update(_delta: float) -> void:
	if not try_exit():
		player.move_and_slide()
