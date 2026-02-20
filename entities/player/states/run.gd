class_name PlayerRunState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.play("to_run")


func process_physics(_delta: float) -> void:
	if try_grounded_transition("PlayerRunState"):
		return
	owner.velocity.x = Input.get_axis("left", "right") * owner.RUN_SPEED
	owner.move_and_slide()
