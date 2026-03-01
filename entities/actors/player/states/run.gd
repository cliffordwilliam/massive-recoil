class_name PlayerRunState
extends PlayerState


func enter(_old: String) -> void:
	owner.body.play("to_run")
	owner.velocity.x = (-owner.RUN_SPEED if owner.body.flip_h else owner.RUN_SPEED)


func process_physics(_delta: float) -> void:
	if not try_exit("PlayerRunState"):
		owner.move_and_slide()
