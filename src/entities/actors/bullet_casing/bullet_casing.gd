# Effect that starts a timer on ready and frees itself when it's done.
class_name BulletCasing
extends RigidBody2D

const EJECT_ANGLE: float = PI / 6
const EJECT_SPREAD: float = PI / 18
const EJECT_SPEED_MIN: float = 150.0
const EJECT_SPEED_MAX: float = 200.0
const SPIN_SPEED: float = 15.0


func initialize(pos: Vector2, facing_left: bool) -> void:
	global_position = pos
	var base_angle: float = EJECT_ANGLE if facing_left else -EJECT_ANGLE
	var spread: float = randf_range(-EJECT_SPREAD, EJECT_SPREAD)
	linear_velocity = Vector2.UP.rotated(base_angle + spread) * randf_range(
		EJECT_SPEED_MIN,
		EJECT_SPEED_MAX,
	)
	angular_velocity = randf_range(-SPIN_SPEED, SPIN_SPEED)


# Autostart is set via the engine GUI.
func _on_timer_timeout() -> void: # Connected via engine GUI
	queue_free()
