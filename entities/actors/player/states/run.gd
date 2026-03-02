class_name PlayerRunState
extends PlayerState


func enter(_old_state: Script) -> void:
	player.body.play("to_run")
	player.velocity.x = (-player.RUN_SPEED if player.body.flip_h else player.RUN_SPEED)


func process_physics(_delta: float) -> void:
	if not try_exit(PlayerRunState):
		player.move_and_slide()
