class_name PlayerRunState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.flip_h_changed.connect(_on_flip_h_changed)
	if (Input.get_axis("left", "right") < 0) != owner.body.flip_h:
		owner.body.set_flip(Input.get_axis("left", "right") < 0)
	else:
		owner.body.play("to_run")


func exit() -> void:
	owner.body.flip_h_changed.disconnect(_on_flip_h_changed)


func process_physics(_delta: float) -> void:
	if try_grounded_transition("PlayerRunState"):
		return
	owner.body.set_flip(Input.get_axis("left", "right") < 0.0)
	owner.velocity.x = Input.get_axis("left", "right") * owner.RUN_SPEED
	owner.move_and_slide()
	if not owner.is_on_floor():
		parent_node.transition_to("PlayerFallState")


func _on_flip_h_changed() -> void:
	owner.body.play("turn")
