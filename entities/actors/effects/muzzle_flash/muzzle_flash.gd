class_name MuzzleFlash
extends AnimatedSprite2D


func init(pos: Vector2, rot: float) -> MuzzleFlash:
	global_position = pos
	rotation = rot
	return self


# Autoplay is set via engine GUI
func _on_animation_finished() -> void: # Connected via engine GUI
	queue_free()
