class_name UIShopItemList
extends Node2D
## Manages a paginated list of `UIShopItem` entries.
##
## This node owns a fixed set of five `UIShopItem` children and displays a
## subset of items from an internal data array. Entries are **not dynamically
## created or destroyed**. Instead, the existing entries are reused and updated
## whenever the current page changes.
##
## The currently selected item is tracked by `_current_index`. Changing this
## index automatically refreshes the visible page.
##
## Rendering behavior is controlled by `RenderMode`, which determines which
## `UIShopItem` setup function is used when displaying items.
##
## Navigation through the list can be performed using `next()` and `previous()`.

## Determines how entries should render the provided item data.
enum RenderMode {
	## Items are rendered using `UIShopItem.setup_buy()`.
	BUY,
	## Items are rendered using `UIShopItem.setup_sell()`.
	SELL,
	## Items are rendered using `UIShopItem.setup_upgrade()`.
	UPGRADE,
}

## Maximum number of entries displayed on a single page.
const _PAGE_SIZE: int = 5

## Scroll thumb width in pixels.
const _SCROLL_BAR_WIDTH: int = 5

## Scroll thumb color.
const _SCROLL_BAR_COLOR: Color = Color("767b84")

## Current rendering mode used when displaying items.
##
## This determines which `UIShopItem` setup function will be called
## for visible entries.
@export var render_mode: RenderMode = RenderMode.BUY:
	set(value):
		if render_mode == value:
			return
		render_mode = value
		_update_page()

## Internal list of items displayed by the shop list.
##
## The list stores generic data objects used by the renderer.
## Each entry represents a [ShopItemState] instance used by the renderer.
var _items: Array[ShopItemState] = []

## Current selected item index within `_items`.
##
## When updated, the value is clamped to a valid range
var _current_index: int = 0:
	set = set_current_index

## References to the fixed `UIShopItem` entry nodes.
##
## These represent the visible slots of the current page.
@onready var _entries: Array[UIShopItem] = [
	$ItemContainer/UIShopItem1 as UIShopItem,
	$ItemContainer/UIShopItem2 as UIShopItem,
	$ItemContainer/UIShopItem3 as UIShopItem,
	$ItemContainer/UIShopItem4 as UIShopItem,
	$ItemContainer/UIShopItem5 as UIShopItem,
]

## The cursor node positioned over the currently selected entry.
@onready var _cursor: Sprite2D = $Cursor

## Top of the scroll track. The full track height represents all pages stacked.
@onready var _scroll_ceiling: Marker2D = $ScrollCeilling

## Bottom of the scroll track.
@onready var _scroll_floor: Marker2D = $ScrollFloor

## X position and top-left anchor for the scroll thumb.
@onready var _scroll_bar_origin: Marker2D = $ScrollBarOrigin

## Background of the scroll track.
@onready var _scrollbar_background: NinePatchRect = $ScrollbarBackground


func _ready() -> void:
	Utils.require(_entries.size() == _PAGE_SIZE, "Entry count must match _PAGE_SIZE")
	_scrollbar_background.show_behind_parent = true  # So that _draw here draws on top of it


## Sets the list of items displayed by this shop list.
##
## Resets the current index and refreshes the visible page.
##
## `new_items` should contain the data objects required by the
## currently selected `RenderMode`.
func set_items(new_items: Array[ShopItemState]) -> void:
	_items = new_items
	_current_index = 0


## Sets the currently selected item index.
##
## The value is clamped to ensure it remains within the valid
## range of `_items`. Changing the index automatically updates
## the visible page.
func set_current_index(value: int) -> void:
	if _items.is_empty():
		_current_index = 0
		_update_page()
		return

	_current_index = clampi(value, 0, _items.size() - 1)
	_update_page()


## Moves the selection to the next item in the list.
func next() -> void:
	set_current_index(_current_index + 1)


## Moves the selection to the previous item in the list.
func previous() -> void:
	set_current_index(_current_index - 1)


## Returns the starting index of the current page.
##
## Pages are calculated using `_PAGE_SIZE`.
func _get_page_start() -> int:
	if _items.is_empty():
		return 0

	# Read this "res://docs/godot/how_to_do_int_division.md".
	@warning_ignore("integer_division")
	return (_current_index / _PAGE_SIZE) * _PAGE_SIZE


## Updates the visible entries based on the current page.
##
## Entries corresponding to valid item indices are rendered using
## the current `RenderMode`. Remaining slots are hidden.
func _update_page() -> void:
	if not is_node_ready():
		return

	var page_start: int = _get_page_start()

	for local_slot: int in _PAGE_SIZE:
		var entry: UIShopItem = _entries[local_slot]
		var item_index: int = page_start + local_slot

		if item_index < _items.size():
			var item: ShopItemState = _items[item_index]
			var data: ShopItemData = item.data

			match render_mode:
				RenderMode.BUY:
					entry.setup_buy(
						data.display_name, data.get_buy_price(), item.is_new, item.sold_out
					)

				RenderMode.SELL:
					entry.setup_sell(data.display_name, item.count, data.get_sell_price())

				RenderMode.UPGRADE:
					entry.setup_upgrade(data.display_name, 0, 0, item.is_new)

			entry.show()
		else:
			entry.hide()

	var selected_slot: int = _current_index % _PAGE_SIZE
	_cursor.position = _entries[selected_slot].position

	queue_redraw()


## Draws the scroll thumb.
##
## The track spans from [member _scroll_ceiling] to [member _scroll_floor].
## The thumb height represents one page relative to the total number of pages,
## and steps downward by one thumb height per page.
##
## Hidden when all items fit on a single page.
func _draw() -> void:
	var total_pages: int = ceili(float(_items.size()) / _PAGE_SIZE)
	if total_pages <= 1:
		return

	var track_top: float = _scroll_ceiling.position.y
	var track_height: float = _scroll_floor.position.y - track_top
	var thumb_height: float = track_height / total_pages

	@warning_ignore("integer_division")
	var current_page: int = _current_index / _PAGE_SIZE

	var thumb_x: float = _scroll_bar_origin.position.x
	var thumb_y: float = track_top + current_page * thumb_height

	draw_rect(Rect2(thumb_x, thumb_y, _SCROLL_BAR_WIDTH, thumb_height), _SCROLL_BAR_COLOR)
