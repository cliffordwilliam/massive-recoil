# TODO: Make this handle empty list, just queue free if it has no items...
class_name ScrollList
extends Node2D

signal item_selected(id: StringName)
signal index_changed(id: StringName)

@export var cursor_scene: PackedScene
@export var page_size: int = 5

var offset: int = 0
var cursor_row: int = 0

@onready var cursor: Sprite2D = cursor_scene.instantiate()


func _ready() -> void:
	$Cursor.add_child(cursor)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down"):
		var dir: int = int(Input.get_axis("up", "down"))
		var abs_i: int = clamp(offset + cursor_row + dir, 0, $Items.get_child_count() - 1)
		offset = clamp(abs_i - cursor_row, 0, max(0, $Items.get_child_count() - page_size))
		cursor_row = abs_i - offset
		_move()
	elif Input.is_action_just_pressed("accept"):
		item_selected.emit($Items.get_child(offset + cursor_row).name)


func set_items(new_items: Array) -> void:
	$Items.get_children().map(func(i: Sprite2D) -> void: i.free())
	new_items.map(func(i: Sprite2D) -> void: $Items.add_child(i))
	_move()


func _move() -> void:
	for i in $Items.get_child_count():
		$Items.get_child(i).visible = (i - offset) >= 0 and (i - offset) < page_size
		if (i - offset) >= 0 and (i - offset) < page_size:
			$Items.get_child(i).position.y = (i - offset) * $Items.get_child(0).get_rect().size.y
	cursor.position.y = cursor_row * $Items.get_child(0).get_rect().size.y
	index_changed.emit($Items.get_child(offset + cursor_row).name)
