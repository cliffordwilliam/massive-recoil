class_name PlayerTurnState
extends PlayerState


func enter(_old: Script) -> void:
	owner.body.set_flip(not owner.body.flip_h)
	owner.body.play("turn")
	owner.velocity.x = 0.0


func _on_body_animation_finished() -> void: # Connected via engine GUI
	if state_machine.current_state == self:
		state_machine.exit_to(PlayerIdleState, PlayerTurnState)
