# Effect that plays tween on ready and queue free when its done
class_name BulletTrail
extends Line2D


func initialize(from: Vector2, to: Vector2) -> void:
	add_point(from)
	add_point(to)

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.125)
	tween.tween_callback(queue_free)
