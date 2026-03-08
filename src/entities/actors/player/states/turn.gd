# State where the player turns around.
# By design, the player is fully committed to the turn duration with no way to cancel it.
class_name PlayerTurnState
extends PlayerState


func enter(_old_state: StringName) -> void:
	# animation_finished is not emitted for looping animations — a looping "turn" would
	# trap the player in this state permanently.
	# Doc ref: docs/godot/classes/class_animatedsprite2d.rst — animation_finished signal:
	# "This signal is not emitted if an animation is looping."
	# Doc ref: docs/godot/classes/class_spriteframes.rst — get_animation_loop():
	# "Returns true if the given animation is configured to loop when it finishes playing."
	Utils.require(
		not player.body.sprite_frames.get_animation_loop(&"turn"),
		"PlayerTurnState: 'turn' animation must not loop — animation_finished will never emit",
	)
	player.body.set_flip(not player.body.is_flipped_h())
	player.body.play("turn")
	player.velocity.x = 0.0


# Trade‑off chosen as better than a connect/disconnect dance.
func _on_body_animation_finished() -> void: # Connected via engine GUI
	if state_machine.current_state == self:
		state_machine.transition_to(IDLE, name)
