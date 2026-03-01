class_name BulletTrail
extends Line2D


func _process(delta: float) -> void:
	modulate.a = move_toward(modulate.a, 0.0, 8.0 * delta)
	if is_zero_approx(modulate.a):
		queue_free()


func init(from: Vector2, to: Vector2) -> BulletTrail:
	add_point(from)
	add_point(to)
	return self
