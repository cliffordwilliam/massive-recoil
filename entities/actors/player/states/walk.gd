class_name PlayerWalkState
extends PlayerState


func enter(_old_state: Script) -> void:
	player.body.play("walk")
	player.velocity.x = (-player.WALK_SPEED if player.body.flip_h else player.WALK_SPEED)


func process_physics(_delta: float) -> void:
	if not try_exit(PlayerWalkState):
		player.move_and_slide()
