class_name ScrollList
extends Node2D

signal item_selected(id: StringName)
signal index_changed(id: StringName)

@export var cursor_scene: PackedScene
@export var page_size: int = 5

var item_h: int = 0
var offset: int = 0
var cursor_row: int = 0
var cursor: Sprite2D

@onready var cursor_container: Node2D = $Cursor
@onready var items_container: Node2D = $Items


func _ready() -> void:
	assert(cursor_scene, "ScrollList: cursor_scene must be set in the inspector")
	cursor = cursor_scene.instantiate()
	cursor_container.add_child(cursor)


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	if Input.is_action_just_pressed("accept"):
		var idx: int = max(0, offset + cursor_row)
		if idx < items_container.get_child_count():
			item_selected.emit(items_container.get_child(idx).name)
			get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down"):
		if not items_container.get_child_count():
			return
		var dir: int = int(Input.get_axis("up", "down"))
		var abs_i: int = clamp(offset + cursor_row + dir, 0, items_container.get_child_count() - 1)
		offset = clamp(abs_i - cursor_row, 0, max(0, items_container.get_child_count() - page_size))
		cursor_row = abs_i - offset
		_move()
		get_viewport().set_input_as_handled()


func set_items(new_items: Array) -> void:
	for old_item in items_container.get_children():
		items_container.remove_child(old_item)
		old_item.queue_free()
	for new_item: ListItem in new_items:
		items_container.add_child(new_item)
	_set_enabled(new_items.size() > 0)
	if new_items.size() == 0:
		offset = 0
		cursor_row = 0
		return
	item_h = int(new_items[0].get_rect().size.y)
	offset = clamp(offset, 0, max(0, new_items.size() - page_size))
	cursor_row = clamp(cursor_row, 0, min(new_items.size(), page_size) - 1)
	_move()


func _set_enabled(enabled: bool) -> void:
	var page: BasePage = get_parent() as BasePage
	if enabled and page and not page.visible:
		return
	process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	visible = enabled


func _move() -> void:
	if not items_container.get_child_count():
		return
	for i in items_container.get_child_count():
		var row: int = i - offset
		var in_view: bool = row >= 0 and row < page_size
		items_container.get_child(i).visible = in_view
		if in_view:
			items_container.get_child(i).position.y = row * item_h
	cursor.position.y = cursor_row * item_h
	var idx: int = max(0, offset + cursor_row)
	if idx < items_container.get_child_count():
		index_changed.emit(items_container.get_child(idx).name)
