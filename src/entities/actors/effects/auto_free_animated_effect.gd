# Effect that plays an animation on ready and queues itself for free when it is done.
class_name AutoFreeAnimatedEffect
# Not an AnimatedSprite2D because each animation has its own offset from this root.
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	assert(
		animated_sprite_2d.sprite_frames,
		"AutoFreeAnimatedEffect: requires sprite_frames assigned",
	)
	if not animated_sprite_2d.sprite_frames:
		push_error("AutoFreeAnimatedEffect: requires sprite_frames assigned")
		return


func initialize(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot


func _on_animated_sprite_2d_animation_finished() -> void: # Connected via engine GUI (one shot).
	queue_free()
