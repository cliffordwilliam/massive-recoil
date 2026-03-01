class_name MuzzleFlash
extends AnimatedSprite2D


func _ready() -> void:
	animation_finished.connect(func() -> void: queue_free())


func init(pos: Vector2, rot: float) -> MuzzleFlash:
	global_position = pos
	rotation = rot
	return self
