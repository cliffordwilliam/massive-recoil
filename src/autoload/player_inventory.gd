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
## re-queries [method get_slots] after each successful call. No signals are emitted;
## callers drive redraws explicitly on success.
##
## Grid size begins at the first tier and advances through [constant _GRID_SIZES]
## each time [method upgrade_grid] is called.
##
## See: "res://docs/decisions/ui_rendering_model.md"

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

## All placed item instances, each occupying a footprint in the grid.
var _slots: Array[ItemState] = []


## Returns [code]true[/code] if [param item_data] can be placed at [param position].
##
## Checks that the item's footprint fits within [member grid_size] and does not
## overlap any existing other item's footprints. Slots in [param excluded_slots] are treated as if
## already removed — used by move and combine checks. Rects in [param extra_rects] are
## treated as additional occupied footprints — used by [method place_batch] during its
## dry run to prevent two planned batches from claiming the same open slot.
func can_place(
	item_data: ItemData,
	position: Vector2i,
	excluded_slots: Array[ItemState] = [],
	extra_rects: Array[Rect2i] = []
) -> bool:
	var footprint: Rect2i = Rect2i(position, item_data.inventory_size)

	if not Rect2i(Vector2i.ZERO, grid_size).encloses(footprint):
		return false

	for slot: ItemState in _slots:
		if slot in excluded_slots:
			continue
		if footprint.intersects(Rect2i(slot.position, slot.data.inventory_size)):
			return false

	for rect: Rect2i in extra_rects:
		if footprint.intersects(rect):
			return false

	return true


## Places a new item identified by [param id] at [param position] with a
## [member ItemState.stack_count] of [param count].
##
## Marks the item as seen in [GameState] on success if it is buyable ([code]buy_price > 0[/code]).
## For internal batch operations (e.g. save loading), use [method _append_slot] directly.
##
## Returns [code]false[/code] without mutating state if [method can_place] fails.
## An out-of-range [param count] is a programmer error and crashes via [method OS.crash].
func place_item(id: StringName, position: Vector2i, count: int = 1) -> bool:
	if not _place_item(id, position, count):
		return false

	# Intentional reach into GameState — PlayerInventory is the single chokepoint where items
	# enter the player's possession. See: "res://docs/decisions/item_architecture.md"
	# Only buyable items are tracked in the seen-set — the NEW badge is a shop-only concept.
	if ItemRegistry.get_item_or_crash(id).is_buyable():
		GameState.mark_shop_item_seen(id)

	return true


## Returns [code]true[/code] if [param id] can be added to the stack at [param position].
##
## Requires a slot whose footprint contains [param position] holding the same item ID
## with remaining capacity.
## Does [b]not[/b] validate [code]count[/code] — the caller is responsible for ensuring
## [code]count > 0[/code] before calling [method add_to_stack].
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
## Does [b]not[/b] call [method GameState.mark_shop_item_seen]. This is
## intentional: stacking is only possible when a slot for the same item already
## exists, which means the item was already placed (and thus already marked
## seen) at some earlier point.
##
## For loot drops and shop purchases, use [method place_batch] instead —
## it finds open slots automatically and correctly calls
## [method GameState.mark_shop_item_seen].
##
## Call [method can_add_to_stack] first — passing an invalid target is a
## programmer error and crashes via [method OS.crash].
##
## Returns the number of units that could not fit (overflow). A partial fill
## is possible when the stack has some but not enough remaining capacity.
func add_to_stack(id: StringName, position: Vector2i, count: int) -> int:
	# Guard against non-positive count: mini(space, negative) would silently decrement stack_count.
	# Checked separately — can_add_to_stack does not validate count.
	(
		Utils
		. require(
			count > 0,
			"PlayerInventory.add_to_stack: count must be positive, got %d" % count,
		)
	)
	(
		Utils
		. require(
			can_add_to_stack(id, position),
			"PlayerInventory.add_to_stack: cannot add '%s' to slot at %s" % [id, position],
		)
	)

	var slot: ItemState = _get_slot_at(position)

	# Pour as much as fits, return the remainder — like topping up a glass.
	# Partial fills are intentional: the caller owns the overflow and decides what to do with it.
	var space: int = slot.data.stack_size - slot.stack_count
	var added: int = mini(space, count)
	slot.stack_count += added

	return count - added


## Places [param count] of [param id] into inventory atomically.
##
## Returns [code]true[/code] if every unit was placed, [code]false[/code] if the
## inventory has insufficient space. On [code]false[/code] no state is mutated —
## the caller should inform the player that the bag is full.
##
## This is the correct entry point for loot drops and shop purchases.
##
## [b]New slots only:[/b] this method always opens new grid slots — it does not
## top up existing partial stacks of the same item. If the player already has a
## partial stack of [param id], a second slot is opened instead. This is deliberate:
## topping up existing stacks during the dry run would require tracking virtual
## per-slot capacity across batches, significantly complicating the implementation
## with little gameplay benefit. The player is responsible for consolidating stacks
## in inventory before buying or picking up more of the same item.
##
## Performs a dry run first via [method _find_open_position] to
## confirm every batch fits before committing any placement. Placement then uses
## [method place_item] so each operation follows the same rules as a direct player
## action. [method place_item] handles seen-marking — calling it once per new slot
## is safe because [method GameState.mark_shop_item_seen] is a set insert and is
## idempotent. Load-save bypasses this method and calls [method _append_slot]
## directly to skip seen-marking, since the seen-set is already captured in saved
## [GameState] data.
func place_batch(id: StringName, count: int) -> bool:
	Utils.require(count > 0, "PlayerInventory.place_batch: count must be positive, got %d" % count)
	var data: ItemData = ItemRegistry.get_item_or_crash(id)

	# Dry run: find all required positions before touching any state.
	# claimed_rects tracks positions already allocated in this dry run so successive
	# batches do not pick the same open slot.
	var positions: Array[Vector2i] = []
	var claimed_rects: Array[Rect2i] = []
	var remaining: int = count
	while remaining > 0:
		var pos: Vector2i = _find_open_position(data, [], claimed_rects)
		if pos == Vector2i(-1, -1):
			return false
		positions.append(pos)
		claimed_rects.append(Rect2i(pos, data.inventory_size))
		remaining -= mini(remaining, data.stack_size)

	# Commit: all positions confirmed, place every batch.
	remaining = count
	for pos: Vector2i in positions:
		var batch: int = mini(remaining, data.stack_size)
		var placed: bool = place_item(id, pos, batch)
		# Dry run verified each position — placed must be true here.
		# The require guards against any future change that breaks that assumption.
		(
			Utils
			. require(
				placed,
				"PlayerInventory.place_batch: place_item failed for '%s' at %s" % [id, pos],
			)
		)
		remaining -= batch

	return true


## Removes the slot whose footprint contains [param position].
##
## Passing a position with no slot is a programmer error and crashes via [method OS.crash].
func remove_item_at(position: Vector2i) -> void:
	var slot: ItemState = _get_slot_at(position)
	Utils.require(slot != null, "PlayerInventory.remove_item_at: no slot at %s" % position)
	_slots.erase(slot)


## Returns [code]true[/code] if the item at [param from_pos] can be moved so that its
## top-left corner is at [param to_pos].
##
## Returns [code]false[/code] if no slot exists at [param from_pos], if [param to_pos]
## would place the item outside the grid, or if the new footprint overlaps any other footprint.
## The item itself is excluded from the overlap check, so moves to adjacent or overlapping
## positions are evaluated correctly.
##
## Call this before [method move_item] — mirrors the [method can_place] /
## [method place_item] pattern.
func can_move_item(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var slot: ItemState = _get_slot_at(from_pos)
	if slot == null:
		return false
	return can_place(slot.data, to_pos, [slot])


## Moves the item at [param from_pos] so its top-left corner is at [param to_pos].
##
## Updates [member ItemState.position] in place, preserving all slot state.
## Call [method can_move_item] first — invalid arguments crash via [method OS.crash].
func move_item(from_pos: Vector2i, to_pos: Vector2i) -> void:
	(
		Utils
		. require(
			can_move_item(from_pos, to_pos),
			"PlayerInventory.move_item: cannot move item from %s to %s" % [from_pos, to_pos],
		)
	)
	var slot: ItemState = _get_slot_at(from_pos)
	slot.position = to_pos


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


## Returns a snapshot of the slot whose footprint contains [param position], or [code]null[/code].
##
## Use this to resolve a UI grid cell position to an item without holding a long-lived reference.
func get_slot_at(position: Vector2i) -> ItemState:
	var slot: ItemState = _get_slot_at(position)
	if slot == null:
		return null
	return slot.create_snapshot()


## Returns [code]true[/code] if the grid can still be upgraded.
##
## Use this to query upgrade availability without performing the upgrade.
func can_upgrade_grid() -> bool:
	return _grid_tier < _GRID_SIZES.size() - 1


## Advances the grid to the next size tier.
##
## Call [method can_upgrade_grid] first — calling this when already at the maximum
## tier is a programmer error and crashes via [method OS.crash].
func upgrade_grid() -> void:
	Utils.require(can_upgrade_grid(), "PlayerInventory.upgrade_grid: already at maximum tier")
	_grid_tier += 1


## Returns [code]true[/code] if the upgrade item at [param upgrade_pos] can be applied
## to the weapon at [param weapon_pos].
##
## Returns [code]false[/code] if either slot is missing, if the types do not match, if
## the weapon's upgrade step for the targeted stat is [code]0[/code], or if the stat is
## already at its maximum value.
func can_upgrade_weapon(weapon_pos: Vector2i, upgrade_pos: Vector2i) -> bool:
	var weapon_slot: ItemState = _get_slot_at(weapon_pos)
	var upgrade_slot: ItemState = _get_slot_at(upgrade_pos)
	if (
		weapon_slot == null
		or weapon_slot.data.type != ItemData.Type.WEAPON
		or upgrade_slot == null
		or upgrade_slot.data.type != ItemData.Type.WEAPON_UPGRADE
	):
		return false

	var wd: WeaponData = weapon_slot.data.weapon_data
	var stats: WeaponStatsState = weapon_slot.weapon_stats_state

	match upgrade_slot.data.upgrade_stat:
		ItemData.UpgradeStat.POWER:
			return wd.power_upgrade_step > 0 and stats.power < wd.power_max
		ItemData.UpgradeStat.RATE_OF_FIRE:
			return wd.rate_of_fire_upgrade_step > 0 and stats.rate_of_fire < wd.rate_of_fire_max
		ItemData.UpgradeStat.RELOAD_SPEED:
			return wd.reload_speed_upgrade_step > 0 and stats.reload_speed < wd.reload_speed_max
		ItemData.UpgradeStat.AMMO_CAPACITY:
			return wd.ammo_capacity_upgrade_step > 0 and stats.ammo_capacity < wd.ammo_capacity_max
		_:
			(
				Utils
				. require(
					false,
					(
						"can_upgrade_weapon: unreachable — upgrade_stat NONE on WEAPON_UPGRADE item '%s'"
						% upgrade_slot.data.id
					)
				)
			)
			# unreachable — satisfies GDScript return-type checker;
			# upgrade_weapon's _ branch omits this since that function is void
			return false


## Applies the upgrade item at [param upgrade_pos] to the weapon at [param weapon_pos]
## and removes the upgrade item from inventory.
##
## Call [method can_upgrade_weapon] first — invalid arguments crash via [method OS.crash].
func upgrade_weapon(weapon_pos: Vector2i, upgrade_pos: Vector2i) -> void:
	(
		Utils
		. require(
			can_upgrade_weapon(weapon_pos, upgrade_pos),
			(
				"PlayerInventory.upgrade_weapon: upgrade not applicable — upgrade at %s → weapon at %s"
				% [upgrade_pos, weapon_pos]
			),
		)
	)

	var weapon_slot: ItemState = _get_slot_at(weapon_pos)
	var upgrade_slot: ItemState = _get_slot_at(upgrade_pos)
	var wd: WeaponData = weapon_slot.data.weapon_data
	var stats: WeaponStatsState = weapon_slot.weapon_stats_state

	match upgrade_slot.data.upgrade_stat:
		ItemData.UpgradeStat.POWER:
			stats.power += wd.power_upgrade_step
		ItemData.UpgradeStat.RATE_OF_FIRE:
			stats.rate_of_fire += wd.rate_of_fire_upgrade_step
		ItemData.UpgradeStat.RELOAD_SPEED:
			stats.reload_speed += wd.reload_speed_upgrade_step
		ItemData.UpgradeStat.AMMO_CAPACITY:
			stats.ammo_capacity += wd.ammo_capacity_upgrade_step
		_:
			(
				Utils
				. require(
					false,
					(
						"PlayerInventory.upgrade_weapon: unreachable — upgrade_stat NONE on WEAPON_UPGRADE item '%s'"
						% upgrade_slot.data.id
					)
				)
			)
			# No return needed — void function.
		# can_upgrade_weapon's _ branch has return false to satisfy the type checker.

	# Erase after the match so a crash in the _ branch never silently consumes the upgrade item.
	_slots.erase(upgrade_slot)


## Returns [code]true[/code] if the items at [param pos_a] and [param pos_b] can be combined.
##
## Returns [code]false[/code] if either position has no slot, if both positions resolve to
## the same slot (including two positions inside one multi-cell item's footprint), or if no
## recipe exists for the two item IDs.
func can_combine_items(pos_a: Vector2i, pos_b: Vector2i) -> bool:
	var slot_a: ItemState = _get_slot_at(pos_a)
	var slot_b: ItemState = _get_slot_at(pos_b)
	if slot_a == null or slot_b == null or slot_a == slot_b:
		return false
	return RecipeRegistry.has_recipe(slot_a.data.id, slot_b.data.id)


## Combines the items at [param h_pos] (held) and [param t_pos] (target) into their recipe
## result, removes both ingredients from inventory, and places the result at the target's
## position.
##
## The result is guaranteed to fit at [param t_pos]'s slot top-left — all recipe items share
## the same [member ItemData.inventory_size], so removing both ingredients always leaves that
## cell free. See: "res://docs/decisions/item_architecture.md"
##
## Call [method can_combine_items] first — invalid arguments crash via [method OS.crash].
func combine_items(h_pos: Vector2i, t_pos: Vector2i) -> void:
	(
		Utils
		. require(
			can_combine_items(h_pos, t_pos),
			"PlayerInventory.combine_items: cannot combine items at %s and %s" % [h_pos, t_pos],
		)
	)

	var h_slot: ItemState = _get_slot_at(h_pos)
	var t_slot: ItemState = _get_slot_at(t_pos)
	var result_id: StringName = RecipeRegistry.get_result(h_slot.data.id, t_slot.data.id)
	var target_pos: Vector2i = t_slot.position

	remove_item_at(h_slot.position)
	remove_item_at(t_slot.position)

	# place_item (not _place_item) is intentional — recipe results entering the
	# player's possession by any means should mark buyable items as seen, per the
	# same rule that applies to drops and shop purchases.
	# See: "res://docs/decisions/item_architecture.md"
	# Guaranteed by RecipeRegistry: all three items in a recipe share the same
	# inventory_size, so t_slot's former position is always free after both
	# ingredients are erased. See: "res://docs/decisions/item_architecture.md"
	var placed: bool = place_item(result_id, target_pos)
	# Both ingredients are already removed at this point. If place_item fails here,
	# crashing is intentional — there is no rollback mechanism, so a hard crash is
	# the only way to stay atomic and avoid leaving inventory in a permanently broken state.
	(
		Utils
		. require(
			placed,
			(
				"PlayerInventory.combine_items: place_item failed for result '%s' at %s"
				% [result_id, target_pos]
			),
		)
	)


## Resets all inventory state for a new game session.
## Call this before starting a new game so no state from a previous session leaks in.
func new_game() -> void:
	_slots.clear()
	_grid_tier = 0


## Returns inventory state serialized for saving.
func get_save_data() -> Dictionary:
	var slots_data: Array[Dictionary] = []
	# slot.data is guaranteed non-null: every entry in _slots is created by
	# _append_slot, which only accepts data coming from ItemRegistry — a null
	# would have already crashed at the call site. No null guard is needed here.
	for slot: ItemState in _slots:
		var slot_dict: Dictionary = {
			"id": slot.data.id as String,
			"stack_count": slot.stack_count,
			"position": {"x": slot.position.x, "y": slot.position.y},
		}
		if slot.data.type == ItemData.Type.WEAPON:
			var stats: WeaponStatsState = slot.weapon_stats_state
			slot_dict["weapon_stats"] = {
				"power": stats.power,
				"rate_of_fire": stats.rate_of_fire,
				"reload_speed": stats.reload_speed,
				"ammo_capacity": stats.ammo_capacity,
			}
		slots_data.append(slot_dict)
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

	# _grid_tier must be restored before slots are parsed — _parse_and_append_slot_entry
	# calls can_place, which derives grid_size from _grid_tier. Reordering these two lines
	# would cause slot position validation to run against the wrong grid dimensions.
	_grid_tier = _parse_grid_tier(save_data)

	var raw_slots: Variant = save_data.get("slots", [])
	Utils.require(raw_slots is Array, "PlayerInventory.load_save: 'slots' is not an Array")

	for raw_entry: Variant in raw_slots as Array:
		Utils.require(
			raw_entry is Dictionary, "PlayerInventory.load_save: slot entry is not a Dictionary"
		)
		_parse_and_append_slot_entry(raw_entry as Dictionary)


## Returns the first open position where [param item_data] fits in the current grid,
## scanning left-to-right, top-to-bottom.
##
## [param excluded_slots] are treated as if already removed — used by move checks.
## [param extra_rects] are treated as additional occupied footprints — used by
## [method place_batch] during its dry run to prevent two planned batches from
## claiming the same open slot.
##
## Returns [code]Vector2i(-1, -1)[/code] if no space is available.
##
## O(W × H × N) — acceptable for the fixed, small grid bounds.
## Revisit with a spatial index if bounds ever grow substantially.
func _find_open_position(
	item_data: ItemData, excluded_slots: Array[ItemState] = [], extra_rects: Array[Rect2i] = []
) -> Vector2i:
	for y: int in grid_size.y:
		for x: int in grid_size.x:
			var pos: Vector2i = Vector2i(x, y)
			if can_place(item_data, pos, excluded_slots, extra_rects):
				return pos
	return Vector2i(-1, -1)


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
		"PlayerInventory.load_save: slot entry 'id' is missing, empty, or not a String"
	)

	var id: StringName = StringName(raw_id as String)
	# No null guard after get_item_or_crash — it already crashes via Utils.require for unknown IDs.
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
	# grid_size is already correct here — load_save restores _grid_tier before parsing slots.
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

	var parsed_count: Variant = Utils.parse_json_int(entry.get("stack_count", null))
	Utils.require(
		parsed_count != null,
		"PlayerInventory.load_save: 'stack_count' missing or not an integer for '%s'" % id
	)

	var count: int = parsed_count as int
	Utils.require(
		count >= ItemSchema.MIN_STACK and count <= data.stack_size,
		(
			"PlayerInventory.load_save: stack_count %d for '%s' out of range [%d, %d]"
			% [count, id, ItemSchema.MIN_STACK, data.stack_size]
		)
	)

	var weapon_stats: WeaponStatsState = null
	if data.type == ItemData.Type.WEAPON:
		# WEAPON items must have the key — _parse_weapon_stats_entry enforces presence and range.
		weapon_stats = _parse_weapon_stats_entry(entry, data)
	else:
		# Symmetric guard: non-WEAPON items must NOT have the key — reject corrupt data early.
		(
			Utils
			. require(
				not entry.has("weapon_stats"),
				"PlayerInventory.load_save: 'weapon_stats' present for non-WEAPON item '%s'" % id,
			)
		)

	_append_slot(data, pos, count, weapon_stats)


## Validates and places [param id] at [param position] with [param count].
##
## Internal implementation called only by [method place_item]. All other callers
## go through [method place_item] so that seen-marking is never skipped.
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
## Validates that [param weapon_stats] is only provided for [constant ItemData.Type.WEAPON]
## items — any other combination crashes via [method OS.crash].
## Callers must ensure [param data] is non-null, [param pos] is a valid placement
## (checked via [method can_place]), and [param count] is already clamped to
## [[constant ItemSchema.MIN_STACK], [member ItemData.stack_size]].
##
## May be called directly when seen-marking must be suppressed (e.g. [method load_save]).
##
## [param weapon_stats] is only accepted for [constant ItemData.Type.WEAPON] slots and
## is used when restoring from save data. When [code]null[/code], weapon slots are
## initialised with each stat set to its [WeaponData] [code]_min[/code] value.
func _append_slot(
	data: ItemData, pos: Vector2i, count: int, weapon_stats: WeaponStatsState = null
) -> void:
	if weapon_stats != null:
		Utils.require(
			data.type == ItemData.Type.WEAPON,
			"PlayerInventory._append_slot: weapon_stats provided for non-WEAPON item '%s'" % data.id
		)
	var resolved_stats: WeaponStatsState = weapon_stats
	if data.type == ItemData.Type.WEAPON and weapon_stats == null:
		resolved_stats = (
			WeaponStatsState
			. new(
				data.weapon_data.power_min,
				data.weapon_data.rate_of_fire_min,
				data.weapon_data.reload_speed_min,
				data.weapon_data.ammo_capacity_min,
			)
		)
	_slots.append(ItemState.new(data, pos, count, resolved_stats))


## Parses and validates the [code]"weapon_stats"[/code] dict from a save slot [param entry]
## and returns an initialised [WeaponStatsState].
##
## Crashes via [method OS.crash] on any missing or out-of-range field.
## Each stat value is validated against the [param data] weapon's min/max range.
func _parse_weapon_stats_entry(entry: Dictionary, data: ItemData) -> WeaponStatsState:
	var raw_ws: Variant = entry.get("weapon_stats", null)
	(
		Utils
		. require(
			raw_ws is Dictionary,
			(
				"PlayerInventory._parse_weapon_stats_entry: 'weapon_stats' missing or not a Dictionary for '%s'"
				% data.id
			)
		)
	)

	var ws: Dictionary = raw_ws as Dictionary
	var wd: WeaponData = data.weapon_data

	var raw_power: Variant = Utils.parse_json_int(ws.get("power", null))
	(
		Utils
		. require(
			raw_power != null,
			(
				"PlayerInventory._parse_weapon_stats_entry: weapon_stats.power missing or invalid for '%s'"
				% data.id
			)
		)
	)
	var power: int = raw_power as int
	Utils.require(
		power >= wd.power_min and power <= wd.power_max,
		(
			"PlayerInventory._parse_weapon_stats_entry: power %d out of range [%d, %d] for '%s'"
			% [power, wd.power_min, wd.power_max, data.id]
		)
	)

	var raw_rof: Variant = Utils.parse_json_int(ws.get("rate_of_fire", null))
	Utils.require(
		raw_rof != null,
		(
			"PlayerInventory._parse_weapon_stats_entry: rate_of_fire missing or invalid for '%s'"
			% data.id
		)
	)
	var rate_of_fire: int = raw_rof as int
	(
		Utils
		. require(
			rate_of_fire >= wd.rate_of_fire_min and rate_of_fire <= wd.rate_of_fire_max,
			(
				"PlayerInventory._parse_weapon_stats_entry: rate_of_fire %d out of range [%d, %d] for '%s'"
				% [rate_of_fire, wd.rate_of_fire_min, wd.rate_of_fire_max, data.id]
			)
		)
	)

	var raw_reload: Variant = Utils.parse_json_int(ws.get("reload_speed", null))
	Utils.require(
		raw_reload != null,
		(
			"PlayerInventory._parse_weapon_stats_entry: reload_speed missing or invalid for '%s'"
			% data.id
		)
	)
	var reload_speed: int = raw_reload as int
	(
		Utils
		. require(
			reload_speed >= wd.reload_speed_min and reload_speed <= wd.reload_speed_max,
			(
				"PlayerInventory._parse_weapon_stats_entry: reload_speed %d out of range [%d, %d] for '%s'"
				% [reload_speed, wd.reload_speed_min, wd.reload_speed_max, data.id]
			)
		)
	)

	var raw_ammo: Variant = Utils.parse_json_int(ws.get("ammo_capacity", null))
	Utils.require(
		raw_ammo != null,
		(
			"PlayerInventory._parse_weapon_stats_entry: ammo_capacity missing or invalid for '%s'"
			% data.id
		)
	)
	var ammo_capacity: int = raw_ammo as int
	(
		Utils
		. require(
			ammo_capacity >= wd.ammo_capacity_min and ammo_capacity <= wd.ammo_capacity_max,
			(
				"PlayerInventory._parse_weapon_stats_entry: ammo_capacity %d out of range [%d, %d] for '%s'"
				% [ammo_capacity, wd.ammo_capacity_min, wd.ammo_capacity_max, data.id]
			)
		)
	)

	return WeaponStatsState.new(power, rate_of_fire, reload_speed, ammo_capacity)


## Returns the slot whose footprint contains [param position], or [code]null[/code].
func _get_slot_at(position: Vector2i) -> ItemState:
	for slot: ItemState in _slots:
		if Rect2i(slot.position, slot.data.inventory_size).has_point(position):
			return slot
	return null
