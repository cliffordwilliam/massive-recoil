class_name PlayerRunState
extends State

func enter(_prev_state: String) -> void:
	owner.animated_sprite.play("to_run")

func process_physics(_delta: float) -> void:
	if not Input.get_axis("ui_left", "ui_right"):
		parent_node.transition_to("PlayerIdleState")
