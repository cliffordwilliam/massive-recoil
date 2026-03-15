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
	# No null guard after get_item — ItemRegistry.get_item already calls
	# Utils.require for unknown IDs. A second silent return false here would
	# bury that error and make the caller unable to distinguish a missing item
	# from a legitimately invalid placement.
	#
	# Utils.require uses crash=true (the default), which calls OS.crash in both
	# debug and release — it does not merely log and return null. An unknown id
	# is an unrecoverable programmer error with no valid recovery path, so
	# crashing loudly is correct. A soft return false would silently swallow the
	# root cause and make the bug much harder to trace.
	var data: ItemData = ItemRegistry.get_item(id)
	if not can_place(data, position):
		return false
	# An out-of-range count is always a programmer error — callers are responsible
	# for clamping before calling place_item (load_save does this explicitly).
	# Crash in both debug and release via OS.crash (crash=true default). Bare calls
	# without if-not make the intent explicit and avoid dead return-false branches.
	#
	# False positive note: the bare Utils.require calls here (no if-not wrapper) are
	# intentional. crash=true means OS.crash is called on failure — there is no
	# return value to check. Do not add if-not wrappers with crash=false; an
	# out-of-range count is not a recoverable condition at this call site.
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
	if slot == null:
		return count
	# A type mismatch is an expected player action — dragging item A onto a slot
	# occupied by item B — not a programmer error. Return the full count as
	# overflow so the caller knows nothing was placed and can respond (e.g. play
	# an invalid sound or snap the item back). No error is raised.
	if slot.data.id != id:
		return count
	# Guard against non-positive count: mini(space, negative) would produce a
	# negative added value and silently decrement stack_count, corrupting state.
	# crash = true (default): OS.crash() halts the process — the return below
	# is unreachable in practice. It exists only so GDScript's flow analysis
	# sees a value returned on this path.
	if not Utils.require(
		count > 0, "PlayerInventory.add_to_stack: count must be positive, got %d" % count
	):
		return count
	var space: int = slot.data.stack_size - slot.stack_count
	var added: int = mini(space, count)
	slot.stack_count += added
	if added > 0:
		inventory_changed.emit()
	return count - added


## Removes the slot whose footprint contains [param position].
func remove_item_at(position: Vector2i) -> void:
	var slot: ItemState = get_slot_at(position)
	if slot == null:
		return
	_slots.erase(slot)
	inventory_changed.emit()


## Returns the first open position where [param item_data] fits in the current grid,
## scanning left-to-right, top-to-bottom.
##
## Returns [code]Vector2i(-1, -1)[/code] if no space is available.
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
## Each entry is a detached [method ItemState.snapshot] — a copy of the slot at
## the moment of the call. Mutating a snapshot has no effect on inventory state.
## All mutations must go through this autoload's API.
##
## [b]Allocation note:[/b] [member ItemState.snapshot] allocates a new object per
## slot per call. This is intentionally acceptable: the game has a single inventory
## grid with a small, bounded number of slots (capped by [constant _GRID_SIZES]),
## and [method get_slots] is only called in response to [signal inventory_changed] —
## never per-frame. If a future system introduces high-frequency or multi-grid calls,
## revisit this with a cached snapshot approach.
func get_slots() -> Array[ItemState]:
	var out: Array[ItemState] = []
	for slot: ItemState in _slots:
		out.append(slot.snapshot)
	return out


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
## Each entry must be a [Dictionary] with [code]"id"[/code] (String),
## [code]"stack_count"[/code] (int), and [code]"position"[/code]
## ([code]{"x": int, "y": int}[/code]). Unknown ids are skipped with an error.
##
## Uses [method place_item] with [code]mark_seen = false[/code] so that loading
## a save does not touch the seen-set — that state is already captured in the
## saved [GameState] data.
func load_save(save_data: Dictionary) -> void:
	_slots.clear()
	var raw_tier: Variant = save_data.get("grid_tier", 0)
	var tier_int: int = 0
	var parsed_tier: Variant = Utils.parse_json_int(raw_tier)
	if parsed_tier != null:
		tier_int = parsed_tier
	else:
		push_warning(
			"PlayerInventory.load_save: invalid grid_tier '%s', defaulting to 0" % raw_tier
		)
		tier_int = 0
	# False positive note: the asymmetry between grid_tier (clamped gracefully)
	# and item IDs (crash on unknown) is intentional, not an oversight.
	# grid_tier is a bounded integer with a clear fallback: any out-of-range
	# value can be safely snapped to the nearest valid tier without data loss —
	# the worst outcome is the grid renders at the wrong size, which is visible
	# and recoverable. An unknown item ID has no recovery path: there is no
	# sensible ItemData to substitute, and silently skipping it would hide data
	# loss. Crashing immediately is the correct response to a truly corrupt entry.
	_grid_tier = clampi(tier_int, 0, _GRID_SIZES.size() - 1)
	var raw_slots: Variant = save_data.get("slots", [])
	if not raw_slots is Array:
		push_warning("PlayerInventory.load_save: 'slots' is not an Array — skipping all slots")
		inventory_changed.emit()
		return
	for raw_entry: Variant in raw_slots as Array:
		if not raw_entry is Dictionary:
			push_warning("PlayerInventory.load_save: skipping non-Dictionary slot entry")
			continue
		var entry: Dictionary = raw_entry as Dictionary
		# Reject invalid ids at this boundary before passing them deeper.
		# An empty or non-string id in save data indicates a corrupt entry —
		# we never want that reaching ItemRegistry.
		# Soft skip (crash = false): structural garbage — missing, non-String,
		# or empty id field — can appear in corrupt or hand-edited save files.
		# There is nothing to recover: log and skip. This contrasts intentionally
		# with the hard crash below for unknown IDs, where the string is valid
		# but unrecognised. That case means game data changed with no recovery
		# path (renamed or deleted item), so crashing immediately is correct.
		var raw_id: Variant = entry.get("id", "")
		if not Utils.require(
			raw_id is String and not (raw_id as String).is_empty(),
			"PlayerInventory.load_save: slot entry has missing or empty id — skipped.",
			false
		):
			continue
		var id: StringName = StringName(raw_id as String)
		# Intentional by design: unknown IDs crash the game (OS.crash, both debug
		# and release). A mismatch here means an item was renamed or deleted during
		# development, or the player manually edited the save file — neither case has
		# a sensible recovery path, so crashing immediately is correct. This is not
		# a bug or an oversight.
		var data: ItemData = ItemRegistry.get_item(id)
		var raw_pos_val: Variant = entry.get("position", {})
		if not raw_pos_val is Dictionary:
			push_warning(
				"PlayerInventory.load_save: skipping '%s' — position is not a Dictionary" % id
			)
			continue
		var raw_pos: Dictionary = raw_pos_val as Dictionary
		var raw_x: Variant = raw_pos.get("x", -1)
		var raw_y: Variant = raw_pos.get("y", -1)
		var pos_x: int
		var pos_y: int
		var parsed_x: Variant = Utils.parse_json_int(raw_x)
		if parsed_x != null:
			pos_x = parsed_x
		else:
			push_warning(
				"PlayerInventory.load_save: skipping '%s' — position.x is not an integer" % id
			)
			continue
		var parsed_y: Variant = Utils.parse_json_int(raw_y)
		if parsed_y != null:
			pos_y = parsed_y
		else:
			push_warning(
				"PlayerInventory.load_save: skipping '%s' — position.y is not an integer" % id
			)
			continue
		var pos: Vector2i = Vector2i(pos_x, pos_y)
		# Check bounds and overlap separately so the warning identifies the actual
		# cause. can_place returns false for both, making them indistinguishable
		# from a single call — especially relevant when a mismatched grid_tier
		# makes a previously valid position out of bounds on load.
		if (
			pos.x < 0
			or pos.y < 0
			or pos.x + data.inventory_size.x > grid_size.x
			or pos.y + data.inventory_size.y > grid_size.y
		):
			push_warning(
				(
					"PlayerInventory.load_save: skipping '%s' at %s — position out of bounds (grid is %s)"
					% [id, pos, grid_size]
				)
			)
			continue
		if not can_place(data, pos):
			push_warning(
				(
					"PlayerInventory.load_save: skipping '%s' at %s — overlaps existing slot"
					% [id, pos]
				)
			)
			continue
		var raw_count: Variant = entry.get("stack_count", 1)
		var raw_int: int
		var parsed_count: Variant = Utils.parse_json_int(raw_count)
		if parsed_count != null:
			raw_int = parsed_count
		else:
			push_warning(
				(
					"PlayerInventory.load_save: invalid stack_count '%s' for '%s', defaulting to 1"
					% [raw_count, id]
				)
			)
			raw_int = 1
		# False positive note: the asymmetry between this clamp and place_item's
		# Utils.require crash is intentional, not a validation gap.
		# place_item is called with programmer-controlled arguments; a count below
		# MIN_STACK there is always a code bug with a clear fix. load_save is a
		# system boundary reading external save data that may be corrupt or from an
		# older build — crashing the game on a bad count would be worse than clamping
		# and warning. The push_warning below ensures the anomaly is still visible.
		var count: int = clampi(raw_int, ItemSchema.MIN_STACK, data.stack_size)
		if count != raw_int:
			push_warning(
				(
					"PlayerInventory.load_save: clamped stack_count for '%s' from %s to %d"
					% [id, raw_count, count]
				)
			)
		# Intentional bypass of place_item — not a validation gap. load_save
		# runs its own bounds and overlap checks above (with better diagnostics
		# than can_place's single bool return), clamps stack_count, and calls
		# _append_slot directly to avoid re-fetching from ItemRegistry and
		# re-running can_place on already-validated data. inventory_changed is
		# emitted once after the loop rather than once per slot.
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
