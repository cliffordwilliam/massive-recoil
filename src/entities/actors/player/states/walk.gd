# State where the player walks forward.
class_name PlayerWalkState
extends PlayerState


func enter(_old_state: StringName) -> void:
	player.body.play("walk")
	player.velocity.x = (-Player.WALK_SPEED if player.body.flip_h else Player.WALK_SPEED)


func physics_update(_delta: float) -> void:
	if not try_exit():
		player.move_and_slide()
