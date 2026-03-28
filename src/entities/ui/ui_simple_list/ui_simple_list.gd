class_name UISimpleList
extends PanelContainer
## A vertically stacked selectable list with a moving cursor.
##
## Add [Control] children to [member _item_container] in the scene editor by enabling
## "Editable Children" on the instance. The list validates at startup that all direct
## children of [member _item_container] are [Control] nodes.

## Index of the currently selected item.
## Repositions the cursor on every write.
var _current_index: int = 0:
	set(value):
		# Self-assignment writes directly to the backing store — no infinite recursion.
		# See: "res://docs/godot/recursion_does_not_happen_in_self_assign_in_its_own_setter.md"
		_current_index = value
		_update_cursor()

## Callbacks registered via [method bind], keyed by item node.
## Write-once per item — set during owner initialisation and never changed.
var _callbacks: Dictionary[Control, Callable] = {}

@onready var _item_container: VBoxContainer = $MarginContainer/ItemContainer
@onready var _cursor: Sprite2D = $Cursor


## Validates children then defers cursor scale computation until after the first layout pass.
func _ready() -> void:
	(
		Utils
		. require(
			_item_container.get_child_count() > 0,
			(
				"UISimpleList._ready: item_container has no children"
				+ " — add Control nodes as children in the scene editor"
			),
		)
	)
	for child: Node in _item_container.get_children():
		(
			Utils
			. require(
				child is Control,
				"UISimpleList._ready: child '%s' is not a Control node" % child.name,
			)
		)
	_cursor.centered = false
	(
		Utils
		. require(
			_cursor.texture != null,
			"UISimpleList._ready: cursor has no texture — assign one in the scene editor",
		)
	)
	var tex_size: Vector2 = _cursor.texture.get_size()
	(
		Utils
		. require(
			tex_size.x > 0.0 and tex_size.y > 0.0,
			"UISimpleList._ready: cursor texture size must be positive, got %s" % tex_size,
		)
	)
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
## is selected. Write-once per item — crashes if [param item] is already bound.
## [param item] must be a direct child of [member _item_container].
func bind(item: Control, callback: Callable) -> void:
	(
		Utils
		. require(
			item.get_parent() == _item_container,
			"UISimpleList.bind: '%s' is not a direct child of item_container" % item.name,
		)
	)
	(
		Utils
		. require(
			not _callbacks.has(item),
			"UISimpleList.bind: '%s' is already bound — bind is write-once per item" % item.name,
		)
	)
	_callbacks[item] = callback


## Calls the callback bound to the currently selected item.
## Crashes if the selected item has no binding — call [method bind] for every item first.
func confirm() -> void:
	var item: Control = get_selected_item()
	(
		Utils
		. require(
			_callbacks.has(item),
			"UISimpleList.confirm: no callback bound for '%s' — call bind() first" % item.name,
		)
	)
	_callbacks[item].call()


## Returns the currently selected item node.
func get_selected_item() -> Control:
	var item: Control = _item_container.get_child(_current_index) as Control
	(
		Utils
		. require(
			item != null,
			"UISimpleList.get_selected_item: child at index %d is not a Control" % _current_index,
		)
	)
	return item


## Positions and scales the cursor to cover the currently selected item.
## Both scale and position are recomputed on every call so the cursor always reflects the
## current layout (the parent overlay may be hidden when [method _ready] runs, giving a stale rect).
func _update_cursor() -> void:
	var item: Control = get_selected_item()
	var rect: Rect2 = item.get_global_rect()
	var tex_size: Vector2 = _cursor.texture.get_size()
	_cursor.global_position = rect.position
	_cursor.scale = Vector2(rect.size.x / tex_size.x, rect.size.y / tex_size.y)
