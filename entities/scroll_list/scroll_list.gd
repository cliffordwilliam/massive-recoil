class_name ScrollList
extends Node2D

signal item_selected(id: String, index: int)
signal index_changed(id: String, index: int)

@export var cursor_scene: PackedScene
@export var page_size: int = 5

var offset: int = 0
var cursor: Sprite2D
var cursor_row: int = 0

@onready var items: Node2D = $Items


func _ready() -> void:
	cursor = cursor_scene.instantiate()
	$Cursor.add_child(cursor)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("down"):
		_move(1)
	elif Input.is_action_just_pressed("up"):
		_move(-1)
	elif Input.is_action_just_pressed("accept"):
		item_selected.emit(items.get_child(offset + cursor_row).name, offset + cursor_row)


func refresh() -> void:
	for i in items.get_child_count():
		var pg_i: int = i - offset
		var in_window: bool = pg_i >= 0 and pg_i < page_size
		items.get_child(i).visible = in_window
		if in_window:
			items.get_child(i).position = Vector2(0, pg_i * items.get_child(0).get_rect().size.y)
	cursor.position = Vector2(0, cursor_row * items.get_child(0).get_rect().size.y)


func _move(dir: int) -> void:
	if cursor_row + dir < 0:
		if offset > 0:
			offset -= 1
			refresh()
			index_changed.emit(items.get_child(offset + cursor_row).name, offset + cursor_row)
	elif cursor_row + dir >= min(page_size, items.get_child_count() - offset):
		if offset + page_size < items.get_child_count():
			offset += 1
			refresh()
			index_changed.emit(items.get_child(offset + cursor_row).name, offset + cursor_row)
	else:
		cursor_row += dir
		cursor.position = Vector2(0, cursor_row * items.get_child(0).get_rect().size.y)
		index_changed.emit(items.get_child(offset + cursor_row).name, offset + cursor_row)
