class_name UIShopItemList
extends Node2D
## Manages a paginated list of [UIShopItem] entries.
##
## Owns a fixed set of five [UIShopItem] children and displays a subset of items
## from an internal data array. The currently selected item is tracked by
## [member _current_index]. Changing this index automatically refreshes the visible page.
##
## [member render_mode] is set once via the Inspector at scene configuration time
## and never changes at runtime — a buy overlay is always BUY, a sell overlay is always SELL.

## Determines whether this list renders items for buying or selling.
enum RenderMode {
	BUY,
	SELL,
}

const _PAGE_SIZE: int = 5
const _SCROLL_BAR_WIDTH: int = 5
const _SCROLL_BAR_COLOR: Color = Color("767b84")

@export var render_mode: RenderMode = RenderMode.BUY

var _buy_items: Array[ItemData] = []
var _sell_items: Array[ItemState] = []

## Clamped to the valid range of the active items array on every write.
## Starts at -1 so the first assignment always triggers [method _update_page].
var _current_index: int = -1:
	set(value):
		var size: int = _buy_items.size() if render_mode == RenderMode.BUY else _sell_items.size()
		_current_index = clampi(value, 0, maxi(0, size - 1))
		_update_page()

@onready var _cursor: Sprite2D = $Cursor
@onready var _scroll_track_top: Marker2D = $ScrollTrackTop
@onready var _scroll_track_bottom: Marker2D = $ScrollTrackBottom
@onready var _scrollbar_background: NinePatchRect = $ScrollbarBackground
@onready var _item_container: Node = $ItemContainer


func _ready() -> void:
	_cursor.centered = false


## Draws the scrollbar thumb when the list spans more than one page.
func _draw() -> void:
	var items_size: int = _buy_items.size() if render_mode == RenderMode.BUY else _sell_items.size()
	var total_pages: int = ceili(float(items_size) / _PAGE_SIZE)
	if total_pages <= 1:
		return
	var track_top: float = _scroll_track_top.position.y
	var track_height: float = _scroll_track_bottom.position.y - track_top
	var thumb_height: float = track_height / total_pages
	@warning_ignore("integer_division")
	var current_page: int = _current_index / _PAGE_SIZE
	var thumb_x: float = _scroll_track_top.position.x
	var thumb_y: float = track_top + current_page * thumb_height
	draw_rect(Rect2(thumb_x, thumb_y, _SCROLL_BAR_WIDTH, thumb_height), _SCROLL_BAR_COLOR)


## Sets the items displayed in buy mode and preserves the current selection.
func set_buy_items(items: Array[ItemData]) -> void:
	_buy_items.assign(items)
	_current_index = _current_index


## Sets the items displayed in sell mode and preserves the current selection.
func set_sell_items(items: Array[ItemState]) -> void:
	_sell_items.assign(items)
	_current_index = _current_index


## Moves the selection to the next item. Clamps at the last item.
func next() -> void:
	_current_index = _current_index + 1


## Moves the selection to the previous item. Clamps at the first item.
func previous() -> void:
	_current_index = _current_index - 1


## Returns the currently selected [ItemData] in buy mode, or [code]null[/code] if empty.
## [b]Why two functions?[/b] GDScript has no union return type — two typed functions
## is the correct trade-off over returning [Variant].
func get_selected_buy_item() -> ItemData:
	if _buy_items.is_empty():
		return null
	return _buy_items[_current_index]


## Returns the currently selected [ItemState] in sell mode, or [code]null[/code] if empty.
func get_selected_sell_item() -> ItemState:
	if _sell_items.is_empty():
		return null
	return _sell_items[_current_index]


func _update_page() -> void:
	var items_size: int = _buy_items.size() if render_mode == RenderMode.BUY else _sell_items.size()

	for child: Node in _item_container.get_children():
		var item: UIShopItem = child as UIShopItem
		@warning_ignore("integer_division")
		var item_index: int = (_current_index / _PAGE_SIZE) * _PAGE_SIZE + child.get_index()

		if item_index < items_size:
			match render_mode:
				RenderMode.BUY:
					var d: ItemData = _buy_items[item_index]
					item.setup_buy(d.ui_name, d.buy_price, GameState.is_shop_item_new(d.id))
				RenderMode.SELL:
					var s: ItemState = _sell_items[item_index]
					item.setup_sell(s.data.ui_name, s.stack_count, s.data.sell_price)
			item.show()
		else:
			item.hide()

	var selected_slot: int = _current_index % _PAGE_SIZE
	_cursor.visible = items_size > 0
	_cursor.global_position = (
		(_item_container.get_child(selected_slot) as UIShopItem).global_position
	)

	_scrollbar_background.visible = ceili(float(items_size) / _PAGE_SIZE) > 1

	queue_redraw()
