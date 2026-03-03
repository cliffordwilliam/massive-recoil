# This must have BasePage parent and only ListItems in its item containers
# ListItems in this collection must be unique
class_name ScrollList
extends Node2D

signal item_selected(id: StringName)
signal render_updated(id: StringName) # Called when cursor moved or population size changes

@export var cursor_scene: PackedScene
@export var page_size: int = 5

var item_height: int = 0
var offset: int = 0
var cursor_row: int = 0
var cursor: Node2D
# Can be toggled on/off (never process and invisible)
# True means I have content (my child count has width)
var is_active: bool = false:
	set(value):
		is_active = value
		process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED
		visible = is_active

@onready var cursor_container: Node2D = $Cursor
@onready var items_container: Node2D = $Items


func _ready() -> void:
	assert(get_parent() is BasePage, "ScrollList: my parent must be a BasePage")
	assert(cursor_scene, "ScrollList: cursor_scene is missing")
	cursor = cursor_scene.instantiate()
	assert(cursor is Node2D, "ScrollList: cursor must inherit Node2D")
	cursor_container.add_child(cursor)


func _unhandled_input(event: InputEvent) -> void:
	# This game uses keyboard input only
	if event is not InputEventKey:
		return

	if items_container.get_child_count() == 0:
		return

	if event.is_action_pressed("accept"):
		var idx: int = clampi(offset + cursor_row, 0, items_container.get_child_count() - 1)
		item_selected.emit(items_container.get_child(idx).name)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("up") or event.is_action_pressed("down"):
		var dir: int = int(Input.get_axis("up", "down"))
		var idx: int = clampi(offset + cursor_row + dir, 0, items_container.get_child_count() - 1)
		offset = clampi(idx - cursor_row, 0, max(0, items_container.get_child_count() - page_size))
		cursor_row = idx - offset
		_update_render()
		get_viewport().set_input_as_handled()


func set_items(new_items: Array[ListItem]) -> void:
	var seen: Dictionary[StringName, bool] = { }
	for i: ListItem in new_items:
		assert(
			not seen.has(i.name),
			"ScrollList: I cannot hold duplicate ListItem name: '%s'" % i.name,
		)
		seen[i.name] = true

	for old_item: ListItem in items_container.get_children():
		# This is okay since no one references my item container content
		items_container.remove_child(old_item)
		old_item.queue_free()

	for new_item: ListItem in new_items:
		items_container.add_child(new_item)

	is_active = items_container.get_child_count() > 0

	if not is_active:
		offset = 0
		cursor_row = 0
		return

	var first_item: ListItem = items_container.get_child(0)
	item_height = first_item.get_height()

	# Population size changed so must ensure that offset and cursor stay within new valid range
	offset = clampi(offset, 0, max(0, items_container.get_child_count() - page_size))
	cursor_row = clampi(cursor_row, 0, min(items_container.get_child_count(), page_size) - 1)
	_update_render()


func _update_render() -> void:
	if not is_active:
		return

	# Adjust page content
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
