class_name PlayerTurnState
extends PlayerState


func enter(_prev_state: StringName) -> void:
	owner.body.set_flip(not owner.body.flip_h)
	owner.body.play("turn")
	owner.velocity.x = 0.0
	owner.body.animation_finished.connect(_on_animation_finished)


func exit() -> void:
	owner.body.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished() -> void:
	try_grounded_transition("PlayerTurnState")
