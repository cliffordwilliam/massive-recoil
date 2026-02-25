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
	if Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down"):
		_move(int(Input.get_axis("up", "down")))
	elif Input.is_action_just_pressed("accept"):
		item_selected.emit(items.get_child(offset + cursor_row).name, offset + cursor_row)


func refresh() -> void:
	for i in items.get_child_count():
		var pg_i: int = i - offset
		items.get_child(i).visible = pg_i >= 0 and pg_i < page_size
		if pg_i >= 0 and pg_i < page_size:
			items.get_child(i).position = Vector2(0, pg_i * items.get_child(0).get_rect().size.y)
	cursor.position = Vector2(0, cursor_row * items.get_child(0).get_rect().size.y)


func _move(dir: int) -> void:
	var absolute_index: int = clamp(offset + cursor_row + dir, 0, items.get_child_count() - 1)
	offset = clamp(absolute_index - cursor_row, 0, max(0, items.get_child_count() - page_size))
	cursor_row = absolute_index - offset
	refresh()
	index_changed.emit(items.get_child(absolute_index).name, absolute_index)
