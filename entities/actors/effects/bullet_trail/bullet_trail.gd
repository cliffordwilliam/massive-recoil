class_name BulletTrail
extends Line2D


func init(from: Vector2, to: Vector2) -> BulletTrail:
	add_point(from)
	add_point(to)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.125)
	tween.tween_callback(queue_free)
	return self
