class_name PlayerTurnState
extends PlayerState


func enter(_old_state: Script) -> void:
	player.body.set_flip(not player.body.flip_h)
	player.body.play("turn")
	player.velocity.x = 0.0


func _on_body_animation_finished() -> void: # Connected via engine GUI
	if state_machine.current_state == self:
		state_machine.exit_to(PlayerIdleState, PlayerTurnState)
