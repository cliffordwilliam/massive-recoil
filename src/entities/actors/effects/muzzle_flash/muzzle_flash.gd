# Effect that plays an animation on ready and queues itself for free when it is done.
class_name MuzzleFlash
extends AnimatedSprite2D


func initialize(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot


# Autoplay set via engine GUI
func _on_animation_finished() -> void: # Connected via engine GUI
	queue_free()
