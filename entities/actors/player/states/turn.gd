class_name PlayerTurnState
extends PlayerState


func enter(_old: String) -> void:
	owner.body.set_flip(not owner.body.flip_h)
	owner.body.play("turn")
	owner.velocity.x = 0.0


func _on_body_animation_finished() -> void: # Connected via engine GUI
	if get_parent().current_state == self: # Fragile but better than connect and disconnect dance
		get_parent().exit_to("PlayerIdleState", "PlayerTurnState")
