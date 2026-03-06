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
	# Store raw global positions here; convert to local in _assign_children_properties().
	# to_local() depends on global_transform which requires the node's parent chain
	# to be established (i.e. the node must be in the scene tree).
	# Calling to_local() here would silently return wrong coordinates if initialize()
	# is ever called before add_child().
	# Doc ref: docs/godot/classes/class_node2d.rst — to_local():
	# "Transforms the provided global position into a position in local coordinate space.
	# The output will be local relative to the Node2D it is called on."
	is_initialized = true
	from_pos = from
	to_pos = to
	if is_node_ready():
		_assign_children_properties()


func _assign_children_properties() -> void:
	add_point(to_local(from_pos))
	add_point(to_local(to_pos))

	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.125)
	tween.tween_callback(queue_free)
