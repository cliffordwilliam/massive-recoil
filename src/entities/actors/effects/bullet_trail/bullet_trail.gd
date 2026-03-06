# Effect that plays a tween on ready and frees itself when it's done.
class_name BulletTrail
extends Line2D

var is_initialized: bool = false
var from_pos: Vector2 = Vector2.ZERO
var to_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	if not is_initialized:
		return
	_assign_children_properties()


func initialize(from: Vector2, to: Vector2) -> void:
	# This can be called before or after my _ready() is called.
	is_initialized = true
	from_pos = to_local(from)
	to_pos = to_local(to)
	if is_node_ready():
		_assign_children_properties()


func _assign_children_properties() -> void:
	add_point(from_pos)
	add_point(to_pos)

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.125)
	tween.tween_callback(queue_free)
