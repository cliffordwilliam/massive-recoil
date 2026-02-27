class_name PlayerRunState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.play("to_run")
	owner.velocity.x = Input.get_axis("left", "right") * owner.RUN_SPEED


func process_physics(_delta: float) -> void:
	if not try_grounded_transition("PlayerRunState"):
		owner.move_and_slide()
