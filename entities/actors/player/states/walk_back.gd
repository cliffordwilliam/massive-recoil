class_name PlayerWalkBackState
extends PlayerState


func enter(_prev_state: String) -> void:
	owner.body.play_backwards("walk")
	owner.velocity.x = (owner.WALK_SPEED if owner.body.flip_h else -owner.WALK_SPEED)


func process_physics(_delta: float) -> void:
	if not try_grounded_exit("PlayerWalkBackState"):
		owner.move_and_slide()
