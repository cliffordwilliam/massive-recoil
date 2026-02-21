class_name Loot
extends RigidBody2D


func init(type: StringName, pos: Vector2) -> void:
	$AnimatedSprite.play(type)
	position = pos
	var angle: float = randf_range(deg_to_rad(-120.0), deg_to_rad(-60.0))
	linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(100.0, 250.0)
