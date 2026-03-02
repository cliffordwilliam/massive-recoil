class_name BulletCasing
extends RigidBody2D


func _ready() -> void:
	get_tree().create_timer(1.5).timeout.connect(
		func() -> void:
			if is_instance_valid(self):
				queue_free()
	)


func init(pos: Vector2, facing_left: bool) -> BulletCasing:
	position = pos
	var base_angle: float = PI / 6 if facing_left else -PI / 6
	var spread: float = randf_range(-PI / 18, PI / 18)
	linear_velocity = Vector2.UP.rotated(base_angle + spread) * randf_range(150.0, 200.0)
	angular_velocity = randf_range(-15.0, 15.0)
	return self
