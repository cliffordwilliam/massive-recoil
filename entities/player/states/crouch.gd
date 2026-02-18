class_name PlayerCrouchState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.play("to_crouch")
	owner.velocity.x = 0.0


func process_physics(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		return parent_node.transition_to("PlayerJumpState")
	if not Input.is_action_pressed("crouch"):
		try_grounded_transition("PlayerCrouchState")
