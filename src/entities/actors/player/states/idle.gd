# State where the player stands still.
class_name PlayerIdleState
extends PlayerState


func enter(previous_state: StringName) -> void:
	player.body.play("stop" if previous_state == &"PlayerRunState" else "idle")
	player.velocity.x = 0.0


func physics_update(_delta: float) -> void:
	# move_and_slide() is intentionally not called here.
	# This game has no gravity and no jumping. All floors use a constant snapping force
	# (floor_snap_length) to keep the player grounded on slopes at all times.
	# Stationary states never need to process physics movement.
	try_exit()
