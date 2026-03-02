class_name PlayerWalkState
extends PlayerState


func enter(_old: Script) -> void:
	owner.body.play("walk")
	owner.velocity.x = (-owner.WALK_SPEED if owner.body.flip_h else owner.WALK_SPEED)


func process_physics(_delta: float) -> void:
	if not try_exit(PlayerWalkState):
		owner.move_and_slide()
