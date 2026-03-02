class_name MuzzleFlash
extends AnimatedSprite2D


func initialize(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot


# Autoplay is set via engine GUI
func _on_animation_finished() -> void: # Connected via engine GUI
	queue_free()
