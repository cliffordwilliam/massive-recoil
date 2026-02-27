class_name PlayerWalkState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.play("walk")
	owner.velocity.x = Input.get_axis("left", "right") * owner.WALK_SPEED


func process_physics(_delta: float) -> void:
	if not try_grounded_transition("PlayerWalkState"):
		owner.move_and_slide()
