# Effect that plays an animation on ready and queues itself for free when it is done.
# Not an AnimatedSprite2D because each animation has its own offset from this root.
class_name AutoFreeAnimatedEffect
extends Node2D

var is_initialized: bool = false
var global_pos: Vector2 = Vector2.ZERO
var rot: float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if not is_initialized:
		return
	_assign_children_properties()


func initialize(pos: Vector2, given_rot: float) -> void:
	# This can be called before or after my _ready() is called.
	is_initialized = true
	global_pos = pos
	rot = given_rot
	if is_node_ready():
		_assign_children_properties()


func _assign_children_properties() -> void:
	if not Utils.require(animated_sprite_2d.sprite_frames != null, "AutoFreeAnimatedEffect: requires sprite_frames assigned"):
		return
	global_position = global_pos
	rotation = rot
	animated_sprite_2d.play()


func _on_animated_sprite_2d_animation_finished() -> void: # Connected via engine GUI (one shot).
	queue_free()
