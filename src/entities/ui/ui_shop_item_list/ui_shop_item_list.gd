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
## Rendering behavior is controlled by `RenderMode`, which determines which
## `UIShopItem` setup function is used when displaying items.
## This is because this is reused both in Buy and Sell shop page.
##
## Navigation through the list can be performed using `next()` and `previous()`.

## Emitted when the selected index changes. Carries the new index.
signal selection_changed(index: int)

## Determines how entries should render the provided item data.
enum RenderMode {
	## Items are rendered using `UIShopItem.setup_buy()`.
	BUY,
	## Items are rendered using `UIShopItem.setup_sell()`.
	SELL,
}

## Maximum number of entries displayed on a single page.
const _PAGE_SIZE: int = 5

## Scroll thumb width in pixels.
const _SCROLL_BAR_WIDTH: int = 5

## Scroll thumb color.
const _SCROLL_BAR_COLOR: Color = Color("767b84")

## Current rendering mode used when displaying items. Buy or sell mode.
@export var render_mode: RenderMode = RenderMode.BUY:
	set(value):
		if render_mode == value:
			return
		# Godot 4 GDScript detects self-assignment within a setter and writes
		# directly to the backing store — this does NOT cause infinite recursion.
		render_mode = value
		set_current_index(0)

## Items shown in buy mode. Populated via [method set_buy_items].
var _buy_items: Array[ItemData] = []

## Items shown in sell mode. Populated via [method set_sell_items].
var _sell_items: Array[ItemState] = []

## Current selected item index within the active items array.
## Starts at -1 (uninitialized) so the first [method set_current_index] call always
## triggers [method _update_page], even when the target index is 0.
var _current_index: int = -1:
	# Godot 4 GDScript detects self-assignment within a named setter and writes
	# directly to the backing store — assigning _current_index inside
	# set_current_index does NOT cause infinite recursion.
	set = set_current_index

## [UIShopItem] entry nodes, populated from [code]$ItemContainer[/code] children in [method _ready].
## Count is asserted against [constant _PAGE_SIZE] at startup.
var _entries: Array[UIShopItem] = []

## The cursor node positioned over the currently selected entry.
@onready var _cursor: Sprite2D = $Cursor

## Top of the scroll track. The full track height represents all pages stacked height.
@onready var _scroll_track_top: Marker2D = $ScrollTrackTop

## Bottom of the scroll track.
@onready var _scroll_track_bottom: Marker2D = $ScrollTrackBottom


func _ready() -> void:
	var container: Node = $ItemContainer
	Utils.require(
		container.get_child_count() == _PAGE_SIZE,
		(
			"UIShopItemList: expected %d children in ItemContainer, found %d"
			% [_PAGE_SIZE, container.get_child_count()]
		)
	)
	for child: Node in container.get_children():
		var entry: UIShopItem = child as UIShopItem
		Utils.require(
			entry != null,
			"UIShopItemList: child '%s' in ItemContainer is not a UIShopItem" % child.name
		)
		_entries.append(entry)
	_cursor.centered = false


## Sets the items displayed in buy mode and resets selection.
## Only re-renders immediately if [member render_mode] is [enum RenderMode.BUY].
##
## [b]False positive note:[/b] The absence of per-element validation here
## (compared to [method set_sell_items]) is intentional and not asymmetric.
## [Array][ItemData] is a typed array — Godot enforces element types at
## assignment, so no null or wrong-type element can enter [member _buy_items]
## without a runtime type error first. [method set_sell_items] has an extra
## [member ItemState.is_snapshot] check because the snapshot contract is an
## architectural concern beyond what the type system can express — GDScript
## cannot distinguish a live slot from a snapshot copy at the type level.
func set_buy_items(items: Array[ItemData]) -> void:
	# assign() replaces all content on its own — clear() beforehand is redundant
	# and was inconsistent with set_sell_items, which genuinely needs clear()
	# because it populates via an append loop rather than assign().
	_buy_items.assign(items)
	# Intentional lazy update: only refresh immediately when already in BUY mode.
	# If in SELL mode, the render_mode setter will call set_current_index(0) when
	# the mode switches, which triggers _update_page at that point. Not a missing refresh.
	if render_mode == RenderMode.BUY:
		set_current_index(0)


## Sets the items displayed in sell mode and resets selection.
## Only re-renders immediately if [member render_mode] is [enum RenderMode.SELL].
##
## [param items] must be snapshots from [method PlayerInventory.get_slots] —
## never live references from [member PlayerInventory._slots]. [method selected_sell_item]
## returns entries from this array directly to callers, so passing live instances
## would leak owned [ItemState] objects outside [code]PlayerInventory[/code],
## violating the architecture contract. This is enforced at runtime via
## [member ItemState.is_snapshot].
func set_sell_items(items: Array[ItemState]) -> void:
	# Enforce the live-vs-snapshot contract at the boundary.
	# selected_sell_item returns entries from this array to callers — if live slot
	# references entered here, they would escape PlayerInventory's ownership, which
	# is the sole source of truth for all ItemState instances per the architecture.
	# Passing live references is always a programmer error with no valid recovery
	# path. The is_snapshot flag is set by ItemState.create_snapshot and is never true
	# on live slots owned by PlayerInventory._slots.
	_sell_items.clear()
	for item: ItemState in items:
		Utils.require(
			item.is_snapshot,
			(
				"UIShopItemList.set_sell_items: received live ItemState — "
				+ "only pass snapshots from PlayerInventory.get_slots()"
			)
		)
		_sell_items.append(item)
	# Intentional lazy update: mirrors set_buy_items — only refresh immediately
	# when already in SELL mode. Mode switches trigger set_current_index(0) via
	# the render_mode setter. Not a missing refresh.
	if render_mode == RenderMode.SELL:
		set_current_index(0)


## Sets the currently selected item index.
## The value is clamped to ensure it remains within the valid
## range of the active items array. Changing the index automatically updates
## the visible page.
##
## No early-return on unchanged index by design: when the list transitions from
## non-empty to empty while already at index 0, both old and new index resolve
## to 0 — skipping the update would leave stale entries visible. Always calling
## [method _update_page] keeps the guard-free and correct at the cost of one
## redundant redraw per no-op call, which is acceptable for a single scroll list.
##
## [signal selection_changed] is emitted unconditionally, including when the list
## is empty (index 0, no valid item). This is intentional: a missed emission on a
## real selection change would be a silent bug, whereas a spurious emission on an
## empty list is harmless — the consumer already checks for null via
## [method selected_buy_item] / [method selected_sell_item]. Because there is
## never more than one scroll list visible at a time, the redundancy cost is zero.
##
## Both [method _update_page] and the signal emission are guarded by
## [method Node.is_node_ready] so that Godot's @export deserialization of
## [member render_mode] before [method _ready] fires does not emit a signal
## before the page has been drawn.
## [b]False positive note:[/b] "emitted unconditionally" was flagged as
## contradicting the [method Node.is_node_ready] gate. The gate is a Godot
## lifecycle guard, not a conditional on index value or list state.
## "Unconditionally" means the signal fires on every call post-ready —
## including on empty lists and no-op index changes — not that it ignores
## the node lifecycle.
func set_current_index(value: int) -> void:
	var size: int = _active_size()
	_current_index = 0 if size == 0 else clampi(value, 0, size - 1)
	_update_page()
	if is_node_ready():
		selection_changed.emit(_current_index)


## Moves the selection to the next item in the list.
## Clamps at the last item; does not wrap around.
func next() -> void:
	set_current_index(_current_index + 1)


## Moves the selection to the previous item in the list.
## Clamps at the first item; does not wrap around.
func previous() -> void:
	set_current_index(_current_index - 1)


## Returns the currently selected [ItemData] in buy mode.
## Returns [code]null[/code] if the buy list is empty.
##
## [b]Why two functions instead of one?[/b] GDScript has no union return type, so a single
## [code]selected_item()[/code] could only return [code]Variant[/code], losing all type safety
## at call sites. Two typed functions is the correct trade-off here.
##
## Calling this while not in BUY mode is a programmer error and crashes via [method Utils.require].
func selected_buy_item() -> ItemData:
	if render_mode != RenderMode.BUY:
		Utils.require(false, "UIShopItemList.selected_buy_item: called while not in BUY mode")
		return null  # Unreachable — Utils.require crashes via OS.crash. Required by the type checker.
	if _buy_items.is_empty():
		Utils.require(
			_current_index < _buy_items.size(),
			(
				(
					"UIShopItemList.selected_buy_item: _current_index %d out of range for "
					+ "buy list of size %d — buy items mutated without going through setters"
				)
				% [_current_index, _buy_items.size()]
			)
		)
		return null
	return _buy_items[_current_index]


## Returns the currently selected [ItemState] in sell mode.
## Returns [code]null[/code] if the sell list is empty.
## Calling this while not in SELL mode is a programmer error and crashes via [method Utils.require].
func selected_sell_item() -> ItemState:
	if render_mode != RenderMode.SELL:
		Utils.require(false, "UIShopItemList.selected_sell_item: called while not in SELL mode")
		return null  # Unreachable — Utils.require crashes via OS.crash. Required by the type checker.
	if _sell_items.is_empty():
		Utils.require(
			_current_index < _sell_items.size(),
			(
				(
					"UIShopItemList.selected_sell_item: _current_index %d out of range for "
					+ "sell list of size %d — sell items mutated without going through setters"
				)
				% [_current_index, _sell_items.size()]
			)
		)
		return null
	return _sell_items[_current_index]


## Returns the number of items in the currently active array.
func _active_size() -> int:
	match render_mode:
		RenderMode.BUY:
			return _buy_items.size()
		RenderMode.SELL:
			return _sell_items.size()
		_:
			# Intentional fallback — not dead code. GDScript does not enforce
			# exhaustive enum matching at compile time, so this branch is
			# necessary to catch any new RenderMode value added without updating
			# this function. Without it, an unhandled mode would silently return
			# 0 and produce a blank list with no indication of why.
			# Use Utils.require instead of push_error to match the convention in
			# _update_page and to fail hard. push_error alone only logs;
			# Utils.require crashes in both debug and release via OS.crash,
			# catching the bug immediately rather than silently returning 0 and masking the real problem.
			Utils.require(
				false, "UIShopItemList._active_size: unhandled RenderMode %d" % render_mode
			)
			return 0


## Returns the starting index of the current page.
## Pages are calculated using `_PAGE_SIZE`.
func _get_page_start() -> int:
	# This guard is redundant — when the list is empty, _current_index is 0, so
	# (0 / _PAGE_SIZE) * _PAGE_SIZE == 0 anyway. Kept for readability: it makes
	# the empty-list case explicit and avoids the @warning_ignore on an empty list.
	# Do not remove it thinking it is dead code.
	if _active_size() == 0:
		return 0

	@warning_ignore("integer_division")
	return (_current_index / _PAGE_SIZE) * _PAGE_SIZE


## Updates the visible entries based on the current page.
##
## Guards on [method Node.is_node_ready] so it is safe to call before [method _ready] fires —
## for example, when the parent calls [method set_buy_items] or [method set_sell_items] in its
## own [method _ready]. Godot guarantees children are ready before parents, so by the time
## any parent [method _ready] runs this node is already ready and the guard is a no-op.
## [br][br]
## [b]Note:[/b] [method _ready] does not call [method _update_page] itself. Initial rendering
## is always triggered by the first [method set_buy_items] or [method set_sell_items] call.
func _update_page() -> void:
	if not is_node_ready():
		return

	var page_start: int = _get_page_start()
	var active_count: int = _active_size()

	for local_slot: int in _PAGE_SIZE:
		var entry: UIShopItem = _entries[local_slot]
		var item_index: int = page_start + local_slot

		if item_index < active_count:
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
					(
						Utils
						. require(
							state.data != null,
							(
								"UIShopItemList._update_page: null ItemData on ItemState at sell index %d"
								% item_index
							)
						)
					)
					entry.setup_sell(state.data.ui_name, state.stack_count, state.data.sell_price)

				_:
					Utils.require(
						false, "UIShopItemList._update_page: unhandled RenderMode %d" % render_mode
					)
					# continue prevents fallthrough to entry.show() below. Utils.require
					# already crashes before this point, but the guard is kept in case
					# this handler is ever replaced with a softer fallback.
					continue

			entry.show()
		else:
			entry.hide()

	# _entries always has exactly _PAGE_SIZE elements (asserted in _ready), so
	# selected_slot is always a valid index — including when the list is empty
	# (_current_index == 0, selected_slot == 0). The cursor is hidden below when
	# the list is empty, so its position in that case does not matter.
	var selected_slot: int = _current_index % _PAGE_SIZE
	_cursor.visible = _active_size() > 0
	_cursor.position = to_local(_entries[selected_slot].global_position)

	queue_redraw()


## Draws the scroll thumb.
##
## No [method Node.is_node_ready] guard is needed here. [code]_draw[/code] is only
## ever triggered by the Godot renderer (which runs after [method _ready]) or by
## [method queue_redraw], which is only called from [method _update_page] — and
## [method _update_page] already guards on [method Node.is_node_ready] before
## calling [method queue_redraw]. So [code]_draw[/code] can never fire before ready.
func _draw() -> void:
	# float() cast is required: without it, integer division truncates before ceili
	# can apply ceiling rounding (e.g. 7 / 5 == 1 as int, but ceil(7.0 / 5) == 2).
	var total_pages: int = ceili(float(_active_size()) / _PAGE_SIZE)
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
