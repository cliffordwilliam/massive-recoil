class_name UISimpleList
extends PanelContainer
## A vertically stacked selectable list with a moving cursor.
##
## Add [Control] children to [member _item_container] in the scene editor by enabling
## "Editable Children" on the instance.

var _current_index: int = 0:
	set(value):
		_current_index = value
		_update_cursor()

var _callbacks: Dictionary[Control, Callable] = {}

@onready var _item_container: VBoxContainer = $MarginContainer/ItemContainer
@onready var _cursor: Sprite2D = $Cursor


func _ready() -> void:
	_cursor.centered = false
	_update_cursor()


## Need to recompute when it turns visible.
## Defer cursor scale computation until after the first layout pass.
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		# await suspends (without blocking other nodes) and resumes after the frame
		# where Godot processes Control sizes — get_global_rect() is valid from that point on.
		await get_tree().process_frame
		_update_cursor()


## Moves the selection to the next item, wrapping around to the first.
func select_next() -> void:
	_current_index = (_current_index + 1) % _item_container.get_child_count()


## Moves the selection to the previous item, wrapping around to the last.
func select_previous() -> void:
	_current_index = (
		(_current_index - 1 + _item_container.get_child_count()) % _item_container.get_child_count()
	)


## Resets the selection to the first item.
func reset_selection() -> void:
	_current_index = 0


## Returns the number of items in the list.
func get_item_count() -> int:
	return _item_container.get_child_count()


## Binds [param callback] to [param item] so [method confirm] calls it when [param item]
## is selected. [param item] must be a direct child of [member _item_container].
func bind(item: Control, callback: Callable) -> void:
	_callbacks[item] = callback


## Calls the callback bound to the currently selected item.
func confirm() -> void:
	_callbacks[get_selected_item()].call()


## Returns the currently selected item node.
func get_selected_item() -> Control:
	return _item_container.get_child(_current_index) as Control


## Positions and scales the cursor to cover the currently selected item.
## Both scale and position are recomputed on every call so the cursor always reflects the
## current layout (the parent overlay may be hidden when [method _ready] runs, giving a stale rect).
func _update_cursor() -> void:
	var item: Control = get_selected_item()
	var rect: Rect2 = item.get_global_rect()
	var tex_size: Vector2 = _cursor.texture.get_size()
	_cursor.global_position = rect.position
	_cursor.scale = Vector2(rect.size.x / tex_size.x, rect.size.y / tex_size.y)
