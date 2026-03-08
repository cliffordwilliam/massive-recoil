# Effect that plays a tween on ready and frees itself when it's done.
class_name BulletTrail
extends Line2D

var is_initialized: bool = false
var from_pos: Vector2 = Vector2.ZERO
var to_pos: Vector2 = Vector2.ZERO
var tween: Tween


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


func _exit_tree() -> void:
	# Defensive kill — create_tween() binds the tween to this node, so the engine
	# already invalidates it automatically when the node exits the tree.
	# The explicit kill ensures no callback (e.g. queue_free) fires if the node is
	# removed mid-animation by an external caller rather than by the tween itself.
	# Doc reference: docs/godot/classes/class_node.rst — create_tween():
	# equivalent to get_tree().create_tween().bind_node(self)
	# Doc reference: docs/godot/classes/class_tween.rst — bind_node()
	tween = Utils.kill_tween(tween)


func _assign_children_properties() -> void:
	clear_points()
	add_point(to_local(from_pos))
	add_point(to_local(to_pos))

	tween = Utils.kill_tween(tween)
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.125)
	tween.tween_callback(queue_free)
