# State where the player walks backward.
class_name PlayerWalkBackState
extends PlayerState


func enter(_old_state: StringName) -> void:
	# Only restart from the end if the animation isn't already playing.
	# play_backwards("walk") always passes from_end=true, snapping to the last frame on every
	# entry and causing a visible pop on rapid direction changes.
	# Passing no name resumes the current animation in reverse without resetting the frame.
	# Doc ref: docs/godot/classes/class_animatedsprite2d.rst — play() / play_backwards()
	if player.body.animation != &"walk":
		player.body.play_backwards("walk")
	else:
		player.body.play_backwards()
	player.velocity.x = (Player.WALK_SPEED if player.body.is_flipped_h() else -Player.WALK_SPEED)


func physics_update(_delta: float) -> void:
	if not try_exit():
		player.move_and_slide()
