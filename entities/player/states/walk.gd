class_name PlayerWalkState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.play("walk")


func process_physics(_delta: float) -> void:
	if try_grounded_transition("PlayerWalkState"):
		return
	owner.velocity.x = Input.get_axis("left", "right") * owner.WALK_SPEED
	owner.move_and_slide()
