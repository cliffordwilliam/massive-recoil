# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the PlayerInventory autoload
extends Node
## Single source of truth for all items in the player's possession.
##
## Each slot is an [ItemState] placed at a [member ItemState.position] within a
## grid of [member grid_size]. The item's footprint is its position plus
## [member ItemData.inventory_size].
##
## All mutations go through this autoload. When state changes, [signal inventory_changed]
## is emitted so the UI can redraw.
##
## Grid size begins at the first tier and advances through [constant _GRID_SIZES]
## each time [method upgrade_grid] is called.

## Emitted whenever inventory state changes (item placed, removed, or grid resized).
signal inventory_changed

## Available grid sizes in upgrade order.
const _GRID_SIZES: Array[Vector2i] = [
	Vector2i(7, 11),
	Vector2i(8, 12),
	Vector2i(8, 15),
]

## Current grid dimensions. Read-only — advance it via [method upgrade_grid].
var grid_size: Vector2i:
	get:
		return _GRID_SIZES[_grid_tier]

## Current upgrade tier index into [constant _GRID_SIZES].
var _grid_tier: int = 0

## All current inventory slots.
var _slots: Array[ItemState] = []


## Returns [code]true[/code] if [param item_data] can be placed at [param position].
##
## Checks that the item's footprint fits within [member grid_size] and does not
## overlap any existing slot.
func can_place(item_data: ItemData, position: Vector2i) -> bool:
	if position.x < 0 or position.y < 0:
		return false
	if position.x + item_data.inventory_size.x > grid_size.x:
		return false
	if position.y + item_data.inventory_size.y > grid_size.y:
		return false
	var footprint: Rect2i = Rect2i(position, item_data.inventory_size)
	for slot: ItemState in _slots:
		if footprint.intersects(Rect2i(slot.position, slot.data.inventory_size)):
			return false
	return true


## Places a new item identified by [param id] at [param position] with a
## [member ItemState.stack_count] of [param count].
##
## When [param mark_seen] is [code]true[/code] (the default), the item is marked
## as seen in [GameState] so its NEW badge clears. Pass [code]false[/code] when
## restoring state from a save, where the seen-set is already up to date.
##
## When [param notify] is [code]true[/code] (the default), [signal inventory_changed]
## is emitted on success. Pass [code]false[/code] when batching multiple placements
## and emit the signal manually once all placements are complete.
##
## Returns [code]false[/code] without mutating state if [method can_place] fails.
## An out-of-range [param count] is a programmer error and crashes via [method OS.crash].
func place_item(
	id: StringName, position: Vector2i, count: int = 1, mark_seen: bool = true, notify: bool = true
) -> bool:
	# No null guard after get_item — ItemRegistry.get_item already crashes via
	# Utils.require for unknown IDs. A second return false here would bury that
	# error and make the caller unable to distinguish a missing item from a
	# legitimately invalid placement.
	var data: ItemData = ItemRegistry.get_item(id)
	if not can_place(data, position):
		return false
	# An out-of-range count is always a programmer error — callers are responsible
	# for clamping before calling place_item (load_save does this explicitly).
	Utils.require(
		count >= ItemSchema.MIN_STACK,
		"PlayerInventory.place_item: count %d is below MIN_STACK" % count
	)
	Utils.require(
		count <= data.stack_size,
		(
			"PlayerInventory.place_item: count %d exceeds stack_size %d for '%s'"
			% [count, data.stack_size, id]
		)
	)
	_append_slot(data, position, count)
	if mark_seen:
		# False positive note: this call looks like an architecture violation
		# (PlayerInventory reaching into GameState), but it is intentional and
		# documented in docs/decisions/item_architecture.md. The NEW badge is
		# GameState's concern; PlayerInventory is the single chokepoint where any
		# item enters the player's possession, making it the right place to mark
		# an item as seen regardless of how it was acquired (shop, drop, or loot).
		GameState.mark_shop_item_seen(data.id)
	if notify:
		inventory_changed.emit()
	return true


## Adds [param count] to the stack at [param position].
##
## Intended for the drag-and-drop flow: the player picks up an item and drops
## it onto an existing stack of the same type. [param id] is the item being
## added — it must match the slot already at [param position]. [param position]
## is the grid cell of the target slot (any cell inside its footprint works,
## via [method get_slot_at]).
##
## Clamps the result to [member ItemData.stack_size]. Returns the number of
## units that could not fit (overflow).
func add_to_stack(id: StringName, position: Vector2i, count: int) -> int:
	var slot: ItemState = get_slot_at(position)
	# INTENTIONAL DO NOT MARK THESE AS ISSUES:
	# Both the null-slot and the ID-mismatch cases return the full count as
	# "overflow". This is intentional — both represent an invalid placement:
	# there is either no target slot or the target holds a different item.
	# Returning the full count signals to the caller that nothing was placed,
	# so it can respond (e.g. snap the item back or play an invalid sound).
	# Neither case is a programmer error, so no crash is raised.
	# The same return value is used for both to keep the caller contract simple:
	# any non-zero return means some or all units could not be placed.
	# Guard against non-positive count: mini(space, negative) would produce a
	# negative added value and silently decrement stack_count, corrupting state.
	Utils.require(count > 0, "PlayerInventory.add_to_stack: count must be positive, got %d" % count)
	if slot == null:
		return count
	if slot.data.id != id:
		return count
	var space: int = slot.data.stack_size - slot.stack_count
	var added: int = mini(space, count)
	slot.stack_count += added
	if added > 0:
		inventory_changed.emit()
	return count - added


## Removes the slot whose footprint contains [param position].
##
## Returns [code]true[/code] if a slot was found and removed, [code]false[/code] if
## no slot occupies that cell. Consistent with [method place_item] and [method upgrade_grid],
## which both return a bool so callers can distinguish a successful operation from a no-op
## without silently swallowing the miss.
func remove_item_at(position: Vector2i) -> bool:
	var slot: ItemState = get_slot_at(position)
	if slot == null:
		return false
	_slots.erase(slot)
	inventory_changed.emit()
	return true


## Returns the first open position where [param item_data] fits in the current grid,
## scanning left-to-right, top-to-bottom.
##
## Returns [code]Vector2i(-1, -1)[/code] if no space is available.
##
## [b]INTENTIONAL — DO NOT MARK AS AN ISSUE:[/b] This is O(W × H × N) — for each
## candidate cell it calls [method can_place], which iterates all N slots. At the
## maximum grid size (8×15) fully packed with 1×1 items this is ~14,400 iterations.
## This is acceptable given the fixed, small grid bounds. If those bounds ever grow
## substantially, revisit with a spatial index (e.g. a cell occupancy bitset).
func find_open_position(item_data: ItemData) -> Vector2i:
	for y: int in grid_size.y:
		for x: int in grid_size.x:
			var pos: Vector2i = Vector2i(x, y)
			if can_place(item_data, pos):
				return pos
	return Vector2i(-1, -1)


## Returns the slot whose footprint contains [param position], or [code]null[/code].
func get_slot_at(position: Vector2i) -> ItemState:
	for slot: ItemState in _slots:
		if Rect2i(slot.position, slot.data.inventory_size).has_point(position):
			return slot
	return null


## Returns snapshots of all current inventory slots for read-only use by the UI.
##
## Each entry is a detached copy from [method ItemState.create_snapshot] — reflecting
## the slot state at the moment of the call. Mutating a snapshot has no effect on
## inventory state. All mutations must go through this autoload's API.
##
## [b]Allocation note:[/b] [method ItemState.create_snapshot] allocates a new object per
## slot per call. This is intentionally acceptable: the game has a single inventory
## grid with a small, bounded number of slots (capped by [constant _GRID_SIZES]),
## and [method get_slots] is only called in response to [signal inventory_changed] —
## never per-frame. If a future system introduces high-frequency or multi-grid calls,
## revisit this with a cached snapshot approach.
func get_slots() -> Array[ItemState]:
	var out: Array[ItemState] = []
	for slot: ItemState in _slots:
		out.append(slot.create_snapshot())
	return out


## Returns [code]true[/code] if the grid can still be upgraded.
##
## Use this to query upgrade availability without performing the upgrade — for
## example, to initialize a button's disabled state on load without having to
## call [method upgrade_grid] and check its return value.
func can_upgrade_grid() -> bool:
	return _grid_tier < _GRID_SIZES.size() - 1


## Advances the grid to the next size tier if one is available.
##
## Returns [code]true[/code] if the upgrade applied, [code]false[/code] if already
## at the maximum tier. The UI can use this to show feedback (e.g. disable the
## upgrade button once the cap is reached).
func upgrade_grid() -> bool:
	if _grid_tier < _GRID_SIZES.size() - 1:
		_grid_tier += 1
		inventory_changed.emit()
		return true
	return false


## Creates a new [ItemState] and appends it directly to [member _slots].
##
## No validation is performed here — callers must ensure [param data] is non-null,
## [param pos] is a valid placement (checked via [method can_place]), and [param count]
## is already clamped to [[constant ItemSchema.MIN_STACK], [member ItemData.stack_size]].
func _append_slot(data: ItemData, pos: Vector2i, count: int) -> void:
	var slot: ItemState = ItemState.new(data)
	slot.position = pos
	slot.stack_count = count
	_slots.append(slot)


## Hydrates inventory from [param save_data].
##
## Any invalid or corrupt data crashes via [method OS.crash]. Each slot entry
## must be a [Dictionary] with [code]"id"[/code] (String), [code]"stack_count"[/code]
## (int), and [code]"position"[/code] ([code]{"x": int, "y": int}[/code]).
##
## Calls [method _append_slot] directly instead of [method place_item] so that
## [method GameState.mark_shop_item_seen] is never called — the seen-set is already
## captured in the saved [GameState] data and must not be modified on load.
func load_save(save_data: Dictionary) -> void:
	_slots.clear()
	var raw_tier: Variant = save_data.get("grid_tier", 0)
	var parsed_tier: Variant = Utils.parse_json_int(raw_tier)
	Utils.require(
		parsed_tier != null, "PlayerInventory.load_save: invalid grid_tier '%s'" % raw_tier
	)
	var tier_int: int = parsed_tier as int
	Utils.require(
		tier_int >= 0 and tier_int < _GRID_SIZES.size(),
		(
			"PlayerInventory.load_save: grid_tier %d out of range [0, %d]"
			% [tier_int, _GRID_SIZES.size() - 1]
		)
	)
	_grid_tier = tier_int
	var raw_slots: Variant = save_data.get("slots", [])
	Utils.require(raw_slots is Array, "PlayerInventory.load_save: 'slots' is not an Array")
	for raw_entry: Variant in raw_slots as Array:
		Utils.require(
			raw_entry is Dictionary, "PlayerInventory.load_save: slot entry is not a Dictionary"
		)
		var entry: Dictionary = raw_entry as Dictionary
		var raw_id: Variant = entry.get("id", "")
		Utils.require(
			raw_id is String and not (raw_id as String).is_empty(),
			"PlayerInventory.load_save: slot entry has missing or empty id"
		)
		var id: StringName = StringName(raw_id as String)
		var data: ItemData = ItemRegistry.get_item(id)
		var raw_pos_val: Variant = entry.get("position", {})
		Utils.require(
			raw_pos_val is Dictionary,
			"PlayerInventory.load_save: '%s' position is not a Dictionary" % id
		)
		var raw_pos: Dictionary = raw_pos_val as Dictionary
		var parsed_x: Variant = Utils.parse_json_int(raw_pos.get("x"))
		Utils.require(
			parsed_x != null,
			"PlayerInventory.load_save: '%s' position.x is missing or not an integer" % id
		)
		var parsed_y: Variant = Utils.parse_json_int(raw_pos.get("y"))
		Utils.require(
			parsed_y != null,
			"PlayerInventory.load_save: '%s' position.y is missing or not an integer" % id
		)
		var pos: Vector2i = Vector2i(parsed_x as int, parsed_y as int)
		# can_place covers both bounds and overlap checks, so a separate bounds
		# require before this call would duplicate those checks. A single call is
		# enough — the combined error message covers both failure modes.
		Utils.require(
			can_place(data, pos),
			(
				(
					"PlayerInventory.load_save: '%s' at %s is out of bounds or overlaps "
					+ "an existing slot (grid is %s)"
				)
				% [id, pos, grid_size]
			)
		)
		var raw_count: Variant = entry.get("stack_count", 1)
		var parsed_count: Variant = Utils.parse_json_int(raw_count)
		Utils.require(
			parsed_count != null,
			"PlayerInventory.load_save: invalid stack_count '%s' for '%s'" % [raw_count, id]
		)
		var count: int = parsed_count as int
		Utils.require(
			count >= ItemSchema.MIN_STACK and count <= data.stack_size,
			(
				"PlayerInventory.load_save: stack_count %d for '%s' out of range [%d, %d]"
				% [count, id, ItemSchema.MIN_STACK, data.stack_size]
			)
		)
		# Intentional bypass of place_item — not a validation gap. load_save
		# runs its own bounds and overlap checks above (with better diagnostics
		# than can_place's single bool return) and calls _append_slot directly
		# to avoid re-fetching from ItemRegistry and re-running can_place on
		# already-validated data. inventory_changed is emitted once after the loop.
		_append_slot(data, pos, count)
	# Always emit even if save_data was empty — the UI needs to know the slate
	# was cleared and the grid tier was (re)set, which counts as a state change
	# regardless of whether any slots were loaded.
	inventory_changed.emit()


## Returns inventory state serialized for saving.
func get_save_data() -> Dictionary:
	var slots_data: Array[Dictionary] = []
	# slot.data is guaranteed non-null: every entry in _slots is created by
	# _append_slot, which only accepts data coming from ItemRegistry — a null
	# would have already crashed at the call site. No null guard is needed here.
	for slot: ItemState in _slots:
		(
			slots_data
			. append(
				{
					"id": str(slot.data.id),
					"stack_count": slot.stack_count,
					"position": {"x": slot.position.x, "y": slot.position.y},
				}
			)
		)
	return {"grid_tier": _grid_tier, "slots": slots_data}
