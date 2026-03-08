# Scrollable list of ListItem nodes. Parent must be BasePage.
# All items in the collection must have unique names.
class_name ScrollList
extends Node2D

signal item_selected(id: StringName)
signal render_updated(id: StringName) # Called when the cursor moves or the population size changes.

@export var cursor_scene: PackedScene
@export var page_size: int = 5

var item_height: int = 0
var offset: int = 0
var cursor_row: int = 0
var cursor: Node2D
# Can be toggled on/off (never processes and stays invisible).
# True when I have items to display (child count > 0).
var is_active: bool = false:
	set(value):
		is_active = value
		# Intentional design — do not flag this in code review.
		# PROCESS_MODE_INHERIT resolves to PROCESS_MODE_ALWAYS via PageRouter (the ancestor),
		# which is always-processing by design (the UI must remain responsive while the game
		# is paused). This node deliberately relies on that ancestor contract.
		# If PageRouter's process_mode ever changes, audit all ScrollList usages.
		# Ref: docs/godot/classes/class_node.rst — PROCESS_MODE_INHERIT:
		# "Inherits process_mode from the node's parent."
		# Ref: docs/godot/classes/class_node.rst — PROCESS_MODE_ALWAYS:
		# "Always process. Keeps processing, ignoring SceneTree.paused."
		process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED
		visible = is_active

@onready var cursor_container: Node2D = $Cursor
@onready var items_container: Node2D = $Items


func _ready() -> void:
	Utils.require(get_parent() is BasePage, "ScrollList: my parent must be a BasePage")

	if not Utils.require(cursor_scene != null, "ScrollList: cursor_scene is missing"):
		return

	cursor = cursor_scene.instantiate()

	if not Utils.require(cursor is Node2D, "ScrollList: cursor must inherit Node2D"):
		# cursor was never added to the scene tree, so queue_free() is wrong here.
		# queue_free() is designed for in-tree nodes — it schedules removal at end-of-frame.
		# free() deletes the object from memory immediately, which is correct for an unparented node.
		# Doc ref: docs/godot/classes/class_node.rst — queue_free():
		# "Unlike with Object.free(), the node is not deleted instantly."
		# Doc ref: docs/godot/classes/class_object.rst — free():
		# "Deletes the object from memory."
		cursor.free()
		return

	cursor_container.add_child(cursor)


func _unhandled_key_input(event: InputEvent) -> void:
	# _unhandled_key_input only fires for InputEventKey — no guard needed.
	# Doc ref: docs/godot/classes/class_node.rst — _unhandled_key_input()
	if items_container.get_child_count() == 0:
		return

	if event.is_action_pressed("accept"):
		_handle_accept()

	# is_action_pressed() rejects echo events by default (allow_echo = false).
	# Holding a direction key sends repeated InputEventKey events with echo = true,
	# which this check ignores — one move per physical key-down is intentional.
	# To support hold-to-scroll in the future, pass allow_echo: true explicitly.
	# Doc reference: docs/godot/classes/class_inputevent.rst — is_action_pressed()
	# Doc reference: docs/godot/classes/class_inputeventkey.rst — echo property
	elif event.is_action_pressed("up") or event.is_action_pressed("down"):
		var dir: int = 1 if event.is_action_pressed("down") else -1
		_handle_navigation(dir)


func set_items(new_items: Array[ListItem]) -> void:
	# Skip duplicate-named items so item_selected always emits the correct id.
	# Utils.require only logs — assert is stripped in release builds, so without
	# this guard a duplicate would silently slip into the list.
	# Doc ref: docs/godot/tutorials/scripting/gdscript/gdscript_basics.rst — Assert keyword:
	# "These assertions are ignored in non-debug builds."
	var seen: Dictionary[StringName, bool] = { }
	var unique_items: Array[ListItem] = []
	for i: ListItem in new_items:
		if not Utils.require(
			i.get_parent() == null,
			"ScrollList: ListItem must be unparented before passing to set_items(): '%s'" % i.name,
		):
			continue
		if not Utils.require(
			not seen.has(i.name),
			"ScrollList: I cannot hold duplicate ListItem name: '%s'" % i.name,
		):
			# The docs note that queue_free() defers deletion and the node remains accessible until
			# end-of-frame — free() is the correct call for out-of-tree nodes.
			# Doc reference: docs/godot/classes/class_node.rst — queue_free()
			i.free()
			continue
		seen[i.name] = true
		unique_items.append(i)

	# get_children() returns an Array snapshot — iterating while calling remove_child() is safe.
	# Doc ref: docs/godot/classes/class_node.rst — get_children():
	# "Returns all children of this node inside an Array."
	for old_item: ListItem in items_container.get_children():
		# remove_child() must come before queue_free().
		# queue_free() is deferred — the node is not removed until the end of the frame.
		# Doc ref: docs/godot/classes/class_node.rst — queue_free():
		# "the node is not deleted instantly, and it can still be accessed before deletion."
		# _update_render() runs later in the same frame and uses get_child_count() / get_child(i)
		# to assign position.y by index. If old items are still children when that runs,
		# they inflate the child count and shift every new item's computed position.
		# remove_child() is immediate, so the child list is clean before new items are added.
		items_container.remove_child(old_item)
		old_item.queue_free()

	for new_item: ListItem in unique_items:
		items_container.add_child(new_item)

	is_active = items_container.get_child_count() > 0

	if not is_active:
		offset = 0
		cursor_row = 0
		return

	var first_item: ListItem = items_container.get_child(0)
	item_height = first_item.get_height()

	# The population size has changed,
	# so ensure that offset and cursor stay within the new valid range.
	offset = clampi(offset, 0, max(0, items_container.get_child_count() - page_size))
	cursor_row = clampi(cursor_row, 0, min(items_container.get_child_count(), page_size) - 1)
	_update_render()


func _handle_accept() -> void:
	var idx: int = clampi(offset + cursor_row, 0, items_container.get_child_count() - 1)
	item_selected.emit(items_container.get_child(idx).name)
	get_viewport().set_input_as_handled()


func _handle_navigation(dir: int) -> void:
	var idx: int = clampi(offset + cursor_row + dir, 0, items_container.get_child_count() - 1)
	offset = clampi(idx - cursor_row, 0, max(0, items_container.get_child_count() - page_size))
	cursor_row = idx - offset
	_update_render()
	get_viewport().set_input_as_handled()


func _update_render() -> void:
	if not is_active:
		return

	# Adjust page content.
	for i in items_container.get_child_count():
		var list_item: ListItem = items_container.get_child(i)
		var row: int = i - offset
		var in_view: bool = row >= 0 and row < page_size
		list_item.visible = in_view
		if in_view:
			list_item.position.y = row * item_height

	cursor.position.y = cursor_row * item_height

	var idx: int = clampi(offset + cursor_row, 0, items_container.get_child_count() - 1)
	render_updated.emit(items_container.get_child(idx).name)
