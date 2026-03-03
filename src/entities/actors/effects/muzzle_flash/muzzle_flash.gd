# Effect that plays animation on ready and queue free when its done
class_name MuzzleFlash
extends AnimatedSprite2D


func initialize(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot


# Autoplay set via engine GUI
func _on_animation_finished() -> void: # Connected via engine GUI
	queue_free()
