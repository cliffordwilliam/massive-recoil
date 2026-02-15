class_name PlayerRunState
extends State

func enter(_prev_state: String) -> void:
	owner.animated_sprite.flip_h_changed.connect(_on_flip_h_changed)
	if (Input.get_axis("ui_left", "ui_right") < 0) != owner.animated_sprite.flip_h:
		owner.animated_sprite.set_flip(Input.get_axis("ui_left", "ui_right") < 0)
	else:
		owner.animated_sprite.play("to_run")

func exit() -> void:
	owner.animated_sprite.flip_h_changed.disconnect(_on_flip_h_changed)

func process_physics(_delta: float) -> void:
	if Input.is_action_pressed("ui_down"):
		return parent_node.transition_to("PlayerCrouchState")
	if Input.is_action_just_pressed("ui_up"):
		return parent_node.transition_to("PlayerJumpState")
	if not Input.get_axis("ui_left", "ui_right"):
		return parent_node.transition_to("PlayerIdleState")
	if Input.get_axis("ui_left", "ui_right") and Input.is_action_pressed("ui_accept"):
		return parent_node.transition_to("PlayerWalkState")

	owner.velocity.x = Input.get_axis("ui_left", "ui_right") * owner.RUN_SPEED
	owner.move_and_slide()
	if not owner.is_on_floor():
		return parent_node.transition_to("PlayerFallState")
	owner.animated_sprite.set_flip(Input.get_axis("ui_left", "ui_right") < 0.0)

func _on_flip_h_changed() -> void:
	owner.animated_sprite.play("turn")
