class_name UIShopItemList
extends Node2D
## Manages a paginated list of `UIShopItem` entries.
##
## This node owns a fixed set of five `UIShopItem` children and displays a
## subset of items from an internal data array.
##
## The currently selected item is tracked by `_current_index`. Changing this
## index automatically refreshes the visible page.
##
## Rendering behavior is controlled by [member render_mode], which determines which
## [UIShopItem] setup function is used when displaying items. Each instance's mode
## is set once via the Inspector at scene configuration time and never changes at
## runtime — a buy overlay is always BUY, a sell overlay is always SELL.
##
## Navigation through the list can be performed using [method next] and [method previous].
## After either call, re-query [method get_selected_buy_item] or [method get_selected_sell_item]
## to get the new selection.

## Determines whether this list renders items for buying or selling.
## [constant RenderMode.NONE] is a sentinel for the unset state before Inspector
## deserialization fires; it is never valid at runtime.
## The game has exactly one buy overlay and one sell overlay.
enum RenderMode {
	NONE,
	BUY,
	SELL,
}

## Maximum number of entries displayed on a single page.
const _PAGE_SIZE: int = 5

## Width in pixels of the scroll thumb drawn by [method _draw].
const _SCROLL_BAR_WIDTH: int = 5

## Color of the scroll thumb drawn by [method _draw].
const _SCROLL_BAR_COLOR: Color = Color("767b84")

## Rendering mode for this instance. Set once in the Inspector; never changed at runtime.
## Write-once — crashes if [param value] is [constant RenderMode.NONE] or if [member render_mode]
## has already been set. Only the [constant RenderMode.NONE] → non-[constant RenderMode.NONE]
## transition is allowed.
@export var render_mode: RenderMode = RenderMode.NONE:
	set(value):
		Utils.require(
			render_mode == RenderMode.NONE and value != RenderMode.NONE,
			(
				"UIShopItemList.render_mode: write-once — value must be non-NONE and cannot be "
				+ "reassigned"
			)
		)
		render_mode = value

## Items available for purchase. Populated by [method set_buy_items]. Only valid in
## [constant RenderMode.BUY] mode.
var _buy_items: Array[ItemData] = []

## Items available for sale. Populated by [method set_sell_items]. Only valid in
## [constant RenderMode.SELL] mode.
var _sell_items: Array[ItemState] = []

## Current selected item index within the active items array.
## Starts at -1 (uninitialized) so the first assignment always triggers [method _update_page],
## even when the target index is 0.
## Clamped to the valid range of the active items array on every write.
##
## No early-return on unchanged index by design: when the list transitions from
## non-empty to empty while already at index 0, both old and new index resolve
## to 0 — skipping the update would leave stale entries visible. Always calling
## [method _update_page] keeps the logic guard-free and correct at the cost of one
## redundant redraw per no-op call, which is acceptable for a single scroll list.
var _current_index: int = -1:
	set(value):
		# Self-assignment writes directly to the backing store — no infinite recursion.
		# See: "res://docs/godot/recursion_does_not_happen_in_self_assign_in_its_own_setter.md"
		#
		# _get_items_size() crashes if render_mode is NONE. This setter is only called
		# from set_buy_items and set_sell_items, both of which guard for their respective
		# modes before mutating _current_index, so render_mode is always set by the time
		# this runs.
		_current_index = clampi(value, 0, maxi(0, _get_items_size() - 1))
		_update_page()

## The cursor node positioned over the currently selected entry.
@onready var _cursor: Sprite2D = $Cursor

## Top of the scroll track. Together with [member _scroll_track_bottom], defines the track height.
@onready var _scroll_track_top: Marker2D = $ScrollTrackTop

## Bottom of the scroll track. Together with [member _scroll_track_top], defines the track height.
@onready var _scroll_track_bottom: Marker2D = $ScrollTrackBottom

## Background panel drawn behind the scroll thumb. Visible only when there is more than one page.
@onready var _scrollbar_background: NinePatchRect = $ScrollbarBackground

## Container holding the fixed set of [UIShopItem] children, one per page slot.
@onready var _item_container: Node = $ItemContainer


func _ready() -> void:
	Utils.require(
		render_mode != RenderMode.NONE,
		"UIShopItemList._ready: render_mode is unset — configure it in the Inspector"
	)

	Utils.require(
		_item_container.get_child_count() == _PAGE_SIZE,
		(
			"UIShopItemList: expected %d children in ItemContainer, found %d"
			% [_PAGE_SIZE, _item_container.get_child_count()]
		)
	)

	for child: Node in _item_container.get_children():
		var entry: UIShopItem = child as UIShopItem
		Utils.require(
			entry != null,
			"UIShopItemList: child '%s' in ItemContainer is not a UIShopItem" % child.name
		)

	_cursor.centered = false

	# This has to be behind this node because this node calls the draw function.
	_scrollbar_background.show_behind_parent = true


## Draws the scroll thumb.
##
## No [method Node.is_node_ready] guard is needed here. [code]_draw[/code] is delivered
## during idle time — after [method _ready] has already fired. This holds because this
## node is always a pre-placed scene child, never dynamically instantiated into a
## visible tree. Whether triggered manually or by the engine, the delivery is deferred
## to idle time, so this method cannot run before the node is ready in this context.
##
## See: "res://docs/godot/how_draw_works.md"
func _draw() -> void:
	# float() cast is required: without it, integer division truncates before ceili
	# can apply ceiling rounding (e.g. 7 / 5 == 1 as int, but ceil(7.0 / 5) == 2).
	var total_pages: int = ceili(float(_get_items_size()) / _PAGE_SIZE)

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


## Sets the items displayed in buy mode and preserves the current selection, clamped to the new
## size.
## Calling this while not in BUY mode is a programmer error and crashes via [method Utils.require].
##
## [b]False positive note:[/b] The absence of an [member ItemState.is_snapshot]-equivalent
## check here (compared to [method set_sell_items]) is intentional and not asymmetric.
## [method set_sell_items] requires that extra check because the snapshot contract is an
## architectural concern beyond what the type system can express — GDScript cannot
## distinguish a live slot from a snapshot copy at the type level. [Array][ItemData]
## carries no equivalent ownership contract, so no analogous check is needed.
func set_buy_items(items: Array[ItemData]) -> void:
	(
		Utils
		. require(
			render_mode == RenderMode.BUY,
			"UIShopItemList.set_buy_items: called while not in BUY mode",
		)
	)

	for item: ItemData in items:
		Utils.require(item != null, "UIShopItemList.set_buy_items: null ItemData in array")

	# assign() converts the untyped Array into a typed Array[T].
	# read "res://docs/godot/how_assign_works.md"
	_buy_items.assign(items)
	_current_index = _current_index


## Sets the items displayed in sell mode and preserves the current selection, clamped to the new
## size.
## Calling this while not in SELL mode is a programmer error and crashes via [method Utils.require].
##
## [param items] must be snapshots from [method PlayerInventory.get_slots] —
## never live references from [member PlayerInventory._slots]. [method get_selected_sell_item]
## returns entries from this array directly to callers, so passing live instances
## would leak owned [ItemState] objects outside [code]PlayerInventory[/code],
## violating the architecture contract. This is enforced at runtime via
## [member ItemState.is_snapshot].
func set_sell_items(items: Array[ItemState]) -> void:
	(
		Utils
		. require(
			render_mode == RenderMode.SELL,
			"UIShopItemList.set_sell_items: called while not in SELL mode",
		)
	)

	# Enforce the snapshot contract described in the docstring above.
	for item: ItemState in items:
		Utils.require(item != null, "UIShopItemList.set_sell_items: null ItemState in array")
		Utils.require(
			item.is_snapshot,
			(
				"UIShopItemList.set_sell_items: received live ItemState — "
				+ "only pass snapshots from PlayerInventory.get_slots()"
			)
		)

	# assign() converts the untyped Array into a typed Array[T].
	# read "res://docs/godot/how_assign_works.md"
	_sell_items.assign(items)
	_current_index = _current_index


## Moves the selection to the next item in the list.
## Clamps at the last item; does not wrap around.
func next() -> void:
	Utils.require(render_mode != RenderMode.NONE, "UIShopItemList.next: render_mode is unset")
	_current_index = _current_index + 1


## Moves the selection to the previous item in the list.
## Clamps at the first item; does not wrap around.
func previous() -> void:
	Utils.require(render_mode != RenderMode.NONE, "UIShopItemList.previous: render_mode is unset")
	_current_index = _current_index - 1


## Returns the currently selected [ItemData] in buy mode.
## Returns [code]null[/code] if the buy list is empty.
##
## [b]Why two functions instead of one?[/b] GDScript has no union return type, so a single
## [code]selected_item()[/code] could only return [code]Variant[/code], losing all type safety
## at call sites. Two typed functions is the correct trade-off here.
##
## Calling this while not in BUY mode is a programmer error and crashes via [method Utils.require].
func get_selected_buy_item() -> ItemData:
	if render_mode != RenderMode.BUY:
		Utils.require(false, "UIShopItemList.get_selected_buy_item: called while not in BUY mode")
		# Unreachable — Utils.require crashes via OS.crash. Required by the type checker.
		return null

	if _buy_items.is_empty():
		return null

	Utils.require(
		_current_index >= 0 and _current_index < _buy_items.size(),
		(
			(
				"UIShopItemList.get_selected_buy_item: _current_index %d out of range [0, %d) "
				+ "— buy items mutated without going through setters"
			)
			% [_current_index, _buy_items.size()]
		)
	)

	return _buy_items[_current_index]


## Returns the currently selected [ItemState] in sell mode.
## Returns [code]null[/code] if the sell list is empty.
## Calling this while not in SELL mode is a programmer error and crashes via [method Utils.require].
func get_selected_sell_item() -> ItemState:
	if render_mode != RenderMode.SELL:
		Utils.require(false, "UIShopItemList.get_selected_sell_item: called while not in SELL mode")
		# Unreachable — Utils.require crashes via OS.crash. Required by the type checker.
		return null

	if _sell_items.is_empty():
		return null

	Utils.require(
		_current_index >= 0 and _current_index < _sell_items.size(),
		(
			(
				"UIShopItemList.get_selected_sell_item: _current_index %d out of range [0, %d) "
				+ "— sell items mutated without going through setters"
			)
			% [_current_index, _sell_items.size()]
		)
	)

	return _sell_items[_current_index]


## Returns the number of items in the currently active array.
func _get_items_size() -> int:
	match render_mode:
		RenderMode.BUY:
			return _buy_items.size()
		RenderMode.SELL:
			return _sell_items.size()
	Utils.require(false, "UIShopItemList._get_items_size: render_mode is unset")
	# Unreachable — Utils.require crashes via OS.crash. Required by the type checker.
	return 0


## Returns the starting index of the current page based on [member _current_index].
func _get_page_start() -> int:
	@warning_ignore("integer_division")
	return (_current_index / _PAGE_SIZE) * _PAGE_SIZE


## Updates the visible entries based on the current page.
##
## [b]Note:[/b] [method _ready] does not call [method _update_page] itself. Initial rendering
## is always triggered by the first [method set_buy_items] or [method set_sell_items] call.
func _update_page() -> void:
	var items_size: int = _get_items_size()
	for entry_index: int in _PAGE_SIZE:
		var entry: UIShopItem = _item_container.get_child(entry_index) as UIShopItem
		var item_index: int = _get_page_start() + entry_index

		if item_index < items_size:
			match render_mode:
				RenderMode.BUY:
					var data: ItemData = _buy_items[item_index]

					Utils.require(
						data != null,
						"UIShopItemList._update_page: null ItemData at buy index %d" % item_index
					)

					entry.setup_buy(
						data.ui_name, data.buy_price, GameState.is_shop_item_new(data.id)
					)

				RenderMode.SELL:
					var state: ItemState = _sell_items[item_index]

					Utils.require(
						state != null,
						"UIShopItemList._update_page: null ItemState at sell index %d" % item_index
					)

					# Guard state.data separately from state itself — BUY items are a
					# single nullable layer, SELL items are ItemState wrappers with an
					# inner ItemData, so two layers need checking.
					Utils.require(
						state.data != null,
						"UIShopItemList._update_page: null ItemData at sell index %d" % item_index
					)

					entry.setup_sell(state.data.ui_name, state.stack_count, state.data.sell_price)

				_:
					Utils.require(false, "UIShopItemList._update_page: render_mode is unset")

			entry.show()
		else:
			entry.hide()

	# ItemContainer always has exactly _PAGE_SIZE children (asserted in _ready), so
	# selected_slot is always a valid index — including when the list is empty
	# (_current_index == 0, selected_slot == 0). The cursor is hidden below when
	# the list is empty, so its position in that case does not matter.
	var selected_slot: int = _current_index % _PAGE_SIZE
	_cursor.visible = items_size > 0
	_cursor.global_position = (
		(_item_container.get_child(selected_slot) as UIShopItem).global_position
	)

	_scrollbar_background.visible = ceili(float(items_size) / _PAGE_SIZE) > 1

	queue_redraw()
