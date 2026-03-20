# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the PlayerInventory autoload
extends Node
## Single source of truth for all items in the player's possession.
##
## Each slot is an [ItemState] placed at a [member ItemState.position] within a
## grid of [member grid_size]. The item's footprint is its position plus
## [member ItemData.inventory_size].
##
## All mutations go through this autoload. Every mutating method returns a result
## (bool or int) that tells the caller whether and how much state changed — the UI
## re-queries [method get_slots] after each successful call.
##
## Grid size begins at the first tier and advances through [constant _GRID_SIZES]
## each time [method upgrade_grid] is called.

## Available grid sizes in upgrade order.
const _GRID_SIZES: Array[Vector2i] = [
	Vector2i(11, 7),
	Vector2i(12, 8),
	Vector2i(15, 8),
]

## Current grid dimensions. Read-only — advance it via [method upgrade_grid].
var grid_size: Vector2i:
	get:
		return _GRID_SIZES[_grid_tier]

## Current upgrade tier index into [constant _GRID_SIZES].
var _grid_tier: int = 0

var _slots: Array[ItemState] = []


## Returns [code]true[/code] if [param item_data] can be placed at [param position].
##
## Checks that the item's footprint fits within [member grid_size] and does not
## overlap any existing slot.
func can_place(item_data: ItemData, position: Vector2i) -> bool:
	var footprint: Rect2i = Rect2i(position, item_data.inventory_size)

	if not Rect2i(Vector2i.ZERO, grid_size).encloses(footprint):
		return false

	for slot: ItemState in _slots:
		if footprint.intersects(Rect2i(slot.position, slot.data.inventory_size)):
			return false

	return true


## Places a new item identified by [param id] at [param position] with a
## [member ItemState.stack_count] of [param count].
##
## Always marks the item as seen in [GameState] on success. For internal batch
## operations (e.g. save loading), use [method _append_slot] directly.
##
## Returns [code]false[/code] without mutating state if [method can_place] fails.
## An out-of-range [param count] is a programmer error and crashes via [method OS.crash].
func place_item(id: StringName, position: Vector2i, count: int = 1) -> bool:
	if not _place_item(id, position, count):
		return false

	# Intentional reach into GameState — PlayerInventory is the single chokepoint where items
	# enter the player's possession. See: "res://docs/decisions/item_architecture.md"
	GameState.mark_shop_item_seen(id)
	return true


## Returns [code]true[/code] if [param id] can be added to the stack at [param position].
##
## Requires a slot at [param position] holding the same item ID with remaining capacity.
## Call this before [method add_to_stack] — mirrors the [method can_place] /
## [method place_item] pattern.
func can_add_to_stack(id: StringName, position: Vector2i) -> bool:
	var slot: ItemState = _get_slot_at(position)
	return slot != null and slot.data.id == id and slot.stack_count < slot.data.stack_size


## Adds [param count] to the stack at [param position].
##
## Intended for the drag-and-drop flow: the player picks up an item and drops
## it onto an existing stack of the same type. [param id] is the item being
## added — it must match the slot already at [param position]. [param position]
## is the grid cell of the target slot (any cell inside its footprint works,
## via [method _get_slot_at]).
##
## Call [method can_add_to_stack] first — passing an invalid target is a
## programmer error and crashes via [method OS.crash].
##
## Returns the number of units that could not fit (overflow). A partial fill
## is possible when the stack has some but not enough remaining capacity.
func add_to_stack(id: StringName, position: Vector2i, count: int) -> int:
	# Guard against non-positive count: mini(space, negative) would silently decrement stack_count.
	(
		Utils
		. require(
			count > 0,
			"PlayerInventory.add_to_stack: count must be positive, got %d" % count,
		)
	)

	var slot: ItemState = _get_slot_at(position)
	Utils.require(slot != null, "PlayerInventory.add_to_stack: no slot at %s" % position)
	(
		Utils
		. require(
			slot.data.id == id,
			(
				"PlayerInventory.add_to_stack: slot at %s holds '%s', expected '%s'"
				% [position, slot.data.id, id]
			),
		)
	)
	(
		Utils
		. require(
			slot.stack_count < slot.data.stack_size,
			"PlayerInventory.add_to_stack: slot at %s is already full" % position,
		)
	)

	# Pour as much as fits, return the remainder — like topping up a glass.
	# Partial fills are intentional: the caller owns the overflow and decides what to do with it.
	var space: int = slot.data.stack_size - slot.stack_count
	var added: int = mini(space, count)
	slot.stack_count += added

	return count - added


## Returns [code]true[/code] if a slot occupies [param position].
##
## Call this before [method remove_item_at] — mirrors the [method can_place] /
## [method place_item] pattern.
func can_remove_item_at(position: Vector2i) -> bool:
	return _get_slot_at(position) != null


## Removes the slot whose footprint contains [param position].
##
## Call [method can_remove_item_at] first — passing a position with no slot is a
## programmer error and crashes via [method OS.crash].
func remove_item_at(position: Vector2i) -> void:
	var slot: ItemState = _get_slot_at(position)
	Utils.require(slot != null, "PlayerInventory.remove_item_at: no slot at %s" % position)
	_slots.erase(slot)


## Returns the first open position where [param item_data] fits in the current grid,
## scanning left-to-right, top-to-bottom.
##
## Returns [code]Vector2i(-1, -1)[/code] if no space is available.
##
## O(W × H × N) — acceptable for the fixed, small grid bounds.
## Revisit with a spatial index if bounds ever grow substantially.
func find_open_position(item_data: ItemData) -> Vector2i:
	for y: int in grid_size.y:
		for x: int in grid_size.x:
			var pos: Vector2i = Vector2i(x, y)

			if can_place(item_data, pos):
				return pos

	return Vector2i(-1, -1)


## Returns snapshots of all current inventory slots for read-only use by the UI.
##
## Each entry is a detached copy from [method ItemState.create_snapshot] — reflecting
## the slot state at the moment of the call. Mutating a snapshot has no effect on
## inventory state. All mutations must go through this autoload's API.
##
## [b]Allocation note:[/b] [method ItemState.create_snapshot] allocates a new object per
## slot per call. Acceptable — the grid is small and this is only called after a
## successful mutation, never per-frame.
func get_slots() -> Array[ItemState]:
	var out: Array[ItemState] = []
	for slot: ItemState in _slots:
		out.append(slot.create_snapshot())
	return out


## Returns [code]true[/code] if the grid can still be upgraded.
##
## Use this to query upgrade availability without performing the upgrade.
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
		return true
	return false


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

	_grid_tier = _parse_grid_tier(save_data)

	var raw_slots: Variant = save_data.get("slots", [])
	Utils.require(raw_slots is Array, "PlayerInventory.load_save: 'slots' is not an Array")

	for raw_entry: Variant in raw_slots as Array:
		Utils.require(
			raw_entry is Dictionary, "PlayerInventory.load_save: slot entry is not a Dictionary"
		)
		_parse_and_append_slot_entry(raw_entry as Dictionary)


## Validates and returns the grid tier from [param save_data].
## Crashes on missing or out-of-range value.
func _parse_grid_tier(save_data: Dictionary) -> int:
	var raw_tier: Variant = save_data.get("grid_tier", null)
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

	return tier_int


## Validates a single slot [param entry] from save data and appends it via [method _append_slot].
## Crashes on any invalid or corrupt field.
func _parse_and_append_slot_entry(entry: Dictionary) -> void:
	var raw_id: Variant = entry.get("id", "")
	Utils.require(
		raw_id is String and not (raw_id as String).is_empty(),
		"PlayerInventory.load_save: slot entry has missing or empty id"
	)

	var id: StringName = StringName(raw_id as String)
	var data: ItemData = ItemRegistry.get_item_or_crash(id)

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
	# can_place covers both bounds and overlap — one call is enough.
	Utils.require(
		can_place(data, pos),
		(
			(
				"PlayerInventory.load_save: '%s' at %s is out of bounds or overlaps an existing "
				+ "slot (grid is %s)"
			)
			% [id, pos, grid_size]
		)
	)

	var raw_count: Variant = entry.get("stack_count", null)
	(
		Utils
		. require(
			raw_count != null,
			"PlayerInventory.load_save: 'stack_count' missing for '%s'" % id,
		)
	)

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

	_append_slot(data, pos, count)


## Validates and places [param id] at [param position] with [param count].
##
## Returns [code]false[/code] without mutating state if [method can_place] fails.
## An out-of-range [param count] is a programmer error and crashes via [method OS.crash].
## Does not mark the item as seen.
func _place_item(id: StringName, position: Vector2i, count: int) -> bool:
	# No null guard after get_item_or_crash — ItemRegistry.get_item_or_crash already crashes via
	# Utils.require for unknown IDs. A second return false here would bury that
	# error and make the caller unable to distinguish a missing item from a
	# legitimately invalid placement.
	var data: ItemData = ItemRegistry.get_item_or_crash(id)

	# An out-of-range count is always a programmer error — callers are responsible
	# for clamping before calling place_item (load_save does this explicitly).
	Utils.require(
		count >= ItemSchema.MIN_STACK,
		"PlayerInventory._place_item: count %d is below MIN_STACK" % count
	)

	Utils.require(
		count <= data.stack_size,
		(
			"PlayerInventory._place_item: count %d exceeds stack_size %d for '%s'"
			% [count, data.stack_size, id]
		)
	)

	if not can_place(data, position):
		return false

	_append_slot(data, position, count)
	return true


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


## Returns the slot whose footprint contains [param position], or [code]null[/code].
func _get_slot_at(position: Vector2i) -> ItemState:
	for slot: ItemState in _slots:
		if Rect2i(slot.position, slot.data.inventory_size).has_point(position):
			return slot

	return null
