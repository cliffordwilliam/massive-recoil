class_name BulletCasing
extends RigidBody2D


func initialize(pos: Vector2, facing_left: bool) -> void:
	global_position = pos
	var base_angle: float = PI / 6 if facing_left else -PI / 6
	var spread: float = randf_range(-PI / 18, PI / 18)
	linear_velocity = Vector2.UP.rotated(base_angle + spread) * randf_range(150.0, 200.0)
	angular_velocity = randf_range(-15.0, 15.0)


# Autostart is set via engine GUI
func _on_timer_timeout() -> void: # Connected via engine GUI
	queue_free()
