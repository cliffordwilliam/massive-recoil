# PlayerInventory autoload
extends Node
## Single source of truth for all items in the player's possession.
##
## Each slot is an [ItemState] placed at a [member ItemState.position] within a
## grid of [member grid_size]. The item's footprint is its position plus
## [member ItemData.inventory_size].
##
## All mutations go through this autoload. Every mutating method returns a result
## that tells the caller whether and how much state changed — the UI
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

var _grid_tier: int = 0
var _slots: Array[ItemState] = []


## Adds [param count] to the stack at [param position].
## Returns the overflow count, or [code]-1[/code] if the slot is invalid or a different item.
func add_to_stack(id: StringName, position: Vector2i, count: int) -> int:
	var slot: ItemState = get_slot_at(position)
	if slot == null or slot.data.id != id or slot.stack_count >= slot.data.stack_size:
		return -1
	var space: int = slot.data.stack_size - slot.stack_count
	var added: int = mini(space, count)
	slot.stack_count += added
	return count - added


## Creates [param count] of [param id] into inventory atomically.
## Used in game actions (e.g. pick up, buy, etc).
## Returns [code]false[/code] if the inventory has insufficient space.
##
## New slots only, does not top up existing stacks.
## See: "res://docs/decisions/item_architecture.md"
func create_batch(id: StringName, count: int) -> bool:
	var data: ItemData = ItemRegistry.get_item(id)

	# Dry run: find all required positions before touching any state.
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

	# Commit: all positions confirmed, create every batch.
	remaining = count
	for pos: Vector2i in positions:
		var batch: int = mini(remaining, data.stack_size)
		_create_item(id, pos, batch)
		remaining -= batch

	return true


## Removes the slot whose footprint contains [param position].
func remove_item_at(position: Vector2i) -> void:
	_slots.erase(get_slot_at(position))


## Moves the item at [param from_pos] so its top-left corner is at [param to_pos].
## Returns [code]false[/code] if no slot exists at [param from_pos] or the placement is invalid.
func move_item(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var slot: ItemState = get_slot_at(from_pos)
	if slot == null or not _can_place(slot.data, to_pos, [slot]):
		return false
	slot.position = to_pos
	return true


## Returns all current inventory slots.
func get_slots() -> Array[ItemState]:
	return _slots


## Returns the slot whose footprint contains [param position], or [code]null[/code].
func get_slot_at(position: Vector2i) -> ItemState:
	for slot: ItemState in _slots:
		if Rect2i(slot.position, slot.data.inventory_size).has_point(position):
			return slot
	return null


## Advances the grid to the next size tier.
## Returns [code]false[/code] if already at the maximum tier.
func upgrade_grid() -> bool:
	if _grid_tier >= _GRID_SIZES.size() - 1:
		return false
	_grid_tier += 1
	return true


## Applies the upgrade item at [param upgrade_pos] to the weapon at [param weapon_pos]
## and removes the upgrade item from inventory.
## Returns [code]false[/code] if the upgrade cannot be applied (wrong types, stat already maxed).
func upgrade_weapon(weapon_pos: Vector2i, upgrade_pos: Vector2i) -> bool:
	var weapon_slot: ItemState = get_slot_at(weapon_pos)
	var upgrade_slot: ItemState = get_slot_at(upgrade_pos)
	if (
		weapon_slot == null
		or weapon_slot.data.type != ItemData.Type.WEAPON
		or upgrade_slot == null
		or upgrade_slot.data.type != ItemData.Type.WEAPON_UPGRADE
	):
		return false

	var track: WeaponTrack = weapon_slot.data.weapon_track
	var idx: WeaponPointer = weapon_slot.weapon_pointer

	match upgrade_slot.data.upgrade_stat:
		ItemData.UpgradeStat.POWER:
			if track.power.step == 0 or idx.power >= track.power.range_max:
				return false
			idx.power += track.power.step
		ItemData.UpgradeStat.RATE_OF_FIRE:
			if track.rate_of_fire.step == 0 or idx.rate_of_fire >= track.rate_of_fire.range_max:
				return false
			idx.rate_of_fire += track.rate_of_fire.step
		ItemData.UpgradeStat.RELOAD_SPEED:
			if track.reload_speed.step == 0 or idx.reload_speed >= track.reload_speed.range_max:
				return false
			idx.reload_speed += track.reload_speed.step
		ItemData.UpgradeStat.AMMO_CAPACITY:
			if track.ammo_capacity.step == 0 or idx.ammo_capacity >= track.ammo_capacity.range_max:
				return false
			idx.ammo_capacity += track.ammo_capacity.step

	_slots.erase(upgrade_slot)
	return true


## Combines the items at [param h_pos] (held) and [param t_pos] (target) into their recipe result.
## Removes both ingredients and places the result at the target's position.
## Returns [code]false[/code] if no recipe exists for the pair.
## See: "res://docs/decisions/item_architecture.md"
func combine_items(h_pos: Vector2i, t_pos: Vector2i) -> bool:
	var h_slot: ItemState = get_slot_at(h_pos)
	var t_slot: ItemState = get_slot_at(t_pos)
	if h_slot == null or t_slot == null or h_slot == t_slot:
		return false

	var result_id: StringName = RecipeRegistry.get_result(h_slot.data.id, t_slot.data.id)
	if not result_id:
		return false

	var target_pos: Vector2i = t_slot.position
	remove_item_at(h_slot.position)
	remove_item_at(t_slot.position)
	_create_item(result_id, target_pos)
	return true


## Displaces the target item at [param target_pos] to its parking position and
## moves the held item to [param to_pos]. Returns the parking position.
## Returns [code]Vector2i(-1, -1)[/code] if the displacement is not possible.
func displace_item(held_pos: Vector2i, to_pos: Vector2i, target_pos: Vector2i) -> Vector2i:
	var held: ItemState = get_slot_at(held_pos)
	var target: ItemState = get_slot_at(target_pos)
	if held == null or target == null or held == target:
		return Vector2i(-1, -1)

	var held_claimed: Array[Rect2i] = [Rect2i(to_pos, held.data.inventory_size)]
	var new_home: Vector2i = _find_open_position(target.data, [held, target], held_claimed)
	if new_home == Vector2i(-1, -1) or not _can_place(held.data, to_pos, [held, target]):
		return Vector2i(-1, -1)

	target.position = new_home
	held.position = to_pos
	return new_home


## Resets all inventory state for a new game session.
func reset_state() -> void:
	_slots.clear()
	_grid_tier = 0


## Returns inventory state serialized for saving.
func get_save_data() -> Dictionary:
	var slots_data: Array[Dictionary] = []

	for slot: ItemState in _slots:
		var slot_dict: Dictionary = {
			"id": slot.data.id as String,
			"stack_count": slot.stack_count,
			"position": {"x": slot.position.x, "y": slot.position.y},
		}
		if slot.data.type == ItemData.Type.WEAPON:
			var pointer: WeaponPointer = slot.weapon_pointer
			slot_dict["weapon_stats"] = {
				"power": pointer.power,
				"rate_of_fire": pointer.rate_of_fire,
				"reload_speed": pointer.reload_speed,
				"ammo_capacity": pointer.ammo_capacity,
			}
		slots_data.append(slot_dict)

	return {"grid_tier": _grid_tier, "slots": slots_data}


## Hydrates inventory from [param save_data].
func load_save(save_data: Dictionary) -> void:
	_slots.clear()
	_grid_tier = int(save_data.get("grid_tier", 0))
	for entry: Variant in save_data.get("slots", []) as Array:
		if entry is Dictionary:
			_parse_and_append_slot_entry(entry as Dictionary)


## Creates a new item identified by [param id] at [param position] with a
## [member ItemState.stack_count] of [param count].
## Marks the item as seen in [GameState] on success if it is buyable.
## Returns [code]false[/code] without mutating state if placement is invalid.
func _create_item(id: StringName, position: Vector2i, count: int = 1) -> bool:
	if not _create(id, position, count):
		return false
	var item: ItemData = ItemRegistry.get_item(id)
	if item and item.buyable:
		GameState.mark_shop_item_seen(id)
	return true


## Returns [code]true[/code] if [param item_data] can be placed at [param position].
##
## Checks that the item's footprint fits within [member grid_size] and does not
## overlap any existing other item's footprints. Slots in [param excluded_slots] are treated as if
## already removed — used by move and combine checks. Rects in [param extra_rects] are
## treated as additional occupied footprints — used by [method create_batch] during its
## dry run to prevent two planned batches from claiming the same open slot.
func _can_place(
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


## Returns the first open position where [param item_data] fits, scans left-to-right top-to-bottom.
## Returns [code]Vector2i(-1, -1)[/code] if no space is available.
func _find_open_position(
	item_data: ItemData, excluded_slots: Array[ItemState] = [], extra_rects: Array[Rect2i] = []
) -> Vector2i:
	for y: int in grid_size.y:
		for x: int in grid_size.x:
			var pos: Vector2i = Vector2i(x, y)
			if _can_place(item_data, pos, excluded_slots, extra_rects):
				return pos
	return Vector2i(-1, -1)


func _create(id: StringName, position: Vector2i, count: int) -> bool:
	var data: ItemData = ItemRegistry.get_item(id)
	if not _can_place(data, position):
		return false
	_append_slot(data, position, count)
	return true


func _append_slot(
	data: ItemData, pos: Vector2i, count: int, weapon_pointer: WeaponPointer = null
) -> void:
	var resolved_pointer: WeaponPointer = weapon_pointer
	if data.type == ItemData.Type.WEAPON and weapon_pointer == null:
		resolved_pointer = (
			WeaponPointer
			. new(
				data.weapon_track.power.range_min,
				data.weapon_track.rate_of_fire.range_min,
				data.weapon_track.reload_speed.range_min,
				data.weapon_track.ammo_capacity.range_min,
			)
		)
	_slots.append(ItemState.new(data, pos, count, resolved_pointer))


func _parse_and_append_slot_entry(entry: Dictionary) -> void:
	var data: ItemData = ItemRegistry.get_item(StringName(entry.get("id", "") as String))
	if data == null:
		return
	var raw_pos: Dictionary = entry.get("position", {})
	var pos: Vector2i = Vector2i(int(raw_pos.get("x", 0)), int(raw_pos.get("y", 0)))
	var count: int = int(entry.get("stack_count", 1))
	var weapon_pointer: WeaponPointer = null
	if data.type == ItemData.Type.WEAPON:
		weapon_pointer = _parse_weapon_stats_entry(entry, data)
	_append_slot(data, pos, count, weapon_pointer)


func _parse_weapon_stats_entry(entry: Dictionary, data: ItemData) -> WeaponPointer:
	var ws: Dictionary = entry.get("weapon_stats", {})
	return (
		WeaponPointer
		. new(
			int(ws.get("power", data.weapon_track.power.range_min)),
			int(ws.get("rate_of_fire", data.weapon_track.rate_of_fire.range_min)),
			int(ws.get("reload_speed", data.weapon_track.reload_speed.range_min)),
			int(ws.get("ammo_capacity", data.weapon_track.ammo_capacity.range_min)),
		)
	)
