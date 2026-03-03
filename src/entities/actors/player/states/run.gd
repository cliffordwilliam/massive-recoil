# State where player runs forward
class_name PlayerRunState
extends PlayerState


func enter(_old_state: StringName) -> void:
	player.body.play("to_run")
	player.velocity.x = (-Player.RUN_SPEED if player.body.flip_h else Player.RUN_SPEED)


func physics_update(_delta: float) -> void:
	if not try_exit():
		player.move_and_slide()
