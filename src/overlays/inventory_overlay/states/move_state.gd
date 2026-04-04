class_name InventoryMoveState
extends InventoryBaseState
## Move state for [InventoryStateMachine].
##
## The cursor becomes the selected item's footprint (a rectangle matching its size).
## Movement keys shift the footprint one cell at a time. Pressing confirm attempts a
## drop; pressing cancel returns to [BrowseState] without modifying inventory.
##
## Drop resolution order:
## 1. Move to empty space
## 2. Stack merge — same ID, stackable, target has enough remaining capacity
## 3. Weapon upgrade — held is WEAPON_UPGRADE, target is WEAPON
## 4. Recipe combine — held and target IDs match a recipe
## 5. Displace — target moves to a free parking position; player then holds the displaced item
## (outcomes 2–4 are mutually exclusive by item_architecture constraints)


func draw() -> void:
	_sm.overlay.draw_item_footprints(_sm.selected_snapshot.position)
	_sm.overlay.draw_move_footprint()


func enter(_old_state: BaseState) -> void:
	_sm.cursor_cell = _sm.selected_snapshot.position
	_sm.overlay.queue_redraw()


func handle_input(event: InputEvent) -> void:
	var dir_x: int = Utils.get_axis(event, InputActions.LEFT, InputActions.RIGHT)
	var dir_y: int = Utils.get_axis(event, InputActions.UP, InputActions.DOWN)
	if dir_x != 0 or dir_y != 0:
		var size: Vector2i = _sm.selected_snapshot.data.inventory_size
		var new_x: int = clampi(_sm.cursor_cell.x + dir_x, 0, PlayerInventory.grid_size.x - size.x)
		var new_y: int = clampi(_sm.cursor_cell.y + dir_y, 0, PlayerInventory.grid_size.y - size.y)
		if new_x != _sm.cursor_cell.x or new_y != _sm.cursor_cell.y:
			_sm.cursor_cell = Vector2i(new_x, new_y)
			_sm.overlay.queue_redraw()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(InputActions.CANCEL):
		_sm.go_to_browse()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(InputActions.ACCEPT):
		_on_drop()
		get_viewport().set_input_as_handled()


func _on_drop() -> void:
	var held: ItemState = _sm.selected_snapshot
	var to_pos: Vector2i = _sm.cursor_cell

	# Confirm on the origin cell is treated as a cancel — puts the item back without
	# requiring the dedicated cancel key.
	if to_pos == held.position:
		_sm.go_to_browse()
		return

	if PlayerInventory.move_item(held.position, to_pos):
		_sm.overlay.refresh_slots()
		_sm.go_to_browse()
		return

	# Footprint is blocked. Find the single interactable item under the footprint
	# (excluding the held item itself). If multiple items overlap, no interaction applies.
	var target: ItemState = _find_unique_target(held, to_pos)
	if target == null:
		return

	_try_drop_onto_occupied(held, target, to_pos)


func _try_drop_onto_occupied(held: ItemState, target: ItemState, to_pos: Vector2i) -> void:
	# Stack merge — same item type, stackable, target has room for at least one unit.
	# Pours as many as fit; if all units transferred, go to browse. If overflow remains,
	# update the held stack count and stay in move state.
	if (
		held.data.id == target.data.id
		and held.data.stackable
		and (target.data.stack_size - target.stack_count) > 0
	):
		var overflow: int = PlayerInventory.add_to_stack(
			held.data.id, target.position, held.stack_count
		)
		if overflow == 0:
			PlayerInventory.remove_item_at(held.position)
			_sm.overlay.refresh_slots()
			_sm.go_to_browse()
		else:
			held.stack_count = overflow
			_sm.overlay.refresh_slots()
			_sm.overlay.queue_redraw()
		return

	# Weapon upgrade — held is WEAPON_UPGRADE, target is WEAPON.
	if held.data.type == ItemData.Type.WEAPON_UPGRADE and target.data.type == ItemData.Type.WEAPON:
		if not PlayerInventory.upgrade_weapon(target.position, held.position):
			# TODO: play disabled-action SFX and show "weapon is maxed" toast.
			return
		_sm.overlay.refresh_slots()
		_sm.go_to_browse()
		return

	# Recipe combine — held and target IDs match a registered recipe.
	if PlayerInventory.combine_items(held.position, target.position):
		_sm.overlay.refresh_slots()
		_sm.go_to_browse()
		return

	# Displace — target moves to a free parking position; held takes to_pos.
	var old_home: Vector2i = target.position
	var displaced_pos: Vector2i = PlayerInventory.displace_item(
		held.position, to_pos, target.position
	)
	if displaced_pos != Vector2i(-1, -1):
		_sm.selected_snapshot = PlayerInventory.get_slot_at(displaced_pos)
		_sm.cursor_cell = old_home
		_sm.overlay.refresh_slots()
		_sm.overlay.queue_redraw()


## Returns the single non-held slot whose footprint overlaps [param to_pos],
## or [code]null[/code] if multiple distinct items overlap (ambiguous destination).
func _find_unique_target(held: ItemState, to_pos: Vector2i) -> ItemState:
	var target: ItemState = null
	for y: int in held.data.inventory_size.y:
		for x: int in held.data.inventory_size.x:
			var slot: ItemState = PlayerInventory.get_slot_at(to_pos + Vector2i(x, y))
			if slot == null or slot.position == held.position:
				continue
			if target == null:
				target = slot
			elif target.position != slot.position:
				return null
	return target
