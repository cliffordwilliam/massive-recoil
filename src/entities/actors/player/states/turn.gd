# State where player turns around
# This is intentional design, player is fully committed to turn duration with no way to cancel
class_name PlayerTurnState
extends PlayerState


func enter(_old_state: StringName) -> void:
	player.body.set_flip(not player.body.flip_h)
	player.body.play("turn")
	player.velocity.x = 0.0


# Tradeoff taken that is better than connect and disconnect dance
func _on_body_animation_finished() -> void: # Connected via engine GUI
	if state_machine.current_state == self:
		state_machine.transition_to(&"PlayerIdleState", name)
