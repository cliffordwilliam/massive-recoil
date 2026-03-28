class_name InventoryMoveState
extends InventoryBaseState
## Move state for [InventoryStateMachine].
##
## The cursor becomes the selected item's footprint (a rectangle matching its size).
## Movement keys shift the footprint one cell at a time. Pressing confirm attempts a
## drop; pressing cancel returns to [BrowseState] without modifying inventory.
##
## Drop resolution order (mutually exclusive by item_architecture constraints):
## 1. Move to empty space
## 2. Stack merge — same ID, stackable, target has enough remaining capacity
## 3. Weapon upgrade — held is WEAPON_UPGRADE, target is WEAPON
## 4. Recipe combine — held and target IDs match a recipe
##
## See: "res://docs/decisions/inventory_overlay.md"


## Draws item footprints (excluding the held item) then the moving footprint via the overlay.
func draw() -> void:
	_sm.overlay.draw_item_footprints(_sm.selected_snapshot.position)
	_sm.overlay.draw_move_footprint()


## Positions the footprint cursor at the held item's current grid position.
func enter(_old_state: BaseState) -> void:
	# Start the footprint at the item's current grid position.
	_sm.cursor_cell = _sm.selected_snapshot.position
	_sm.overlay.queue_redraw()


## Shifts the footprint with movement keys; confirm attempts a drop; cancel aborts without mutation.
func handle_input(event: InputEvent) -> void:
	var dir_x: int = (
		int(event.is_action_pressed(InputActions.RIGHT))
		- int(event.is_action_pressed(InputActions.LEFT))
	)
	var dir_y: int = (
		int(event.is_action_pressed(InputActions.DOWN))
		- int(event.is_action_pressed(InputActions.UP))
	)
	if dir_x != 0 or dir_y != 0:
		var size: Vector2i = _sm.selected_snapshot.data.inventory_size
		var new_x: int = clampi(_sm.cursor_cell.x + dir_x, 0, PlayerInventory.grid_size.x - size.x)
		var new_y: int = clampi(_sm.cursor_cell.y + dir_y, 0, PlayerInventory.grid_size.y - size.y)
		if new_x != _sm.cursor_cell.x or new_y != _sm.cursor_cell.y:
			_sm.cursor_cell = Vector2i(new_x, new_y)
			_sm.overlay.queue_redraw()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(InputActions.CANCEL):
		# Item remains at its original position — no inventory calls needed.
		_sm.go_to_browse()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(InputActions.ACCEPT):
		_on_drop()
		get_viewport().set_input_as_handled()
	#elif event.is_action_pressed(InputActions.ROTATE):
	# TODO: rotation requires is_rotated on ItemState — not yet implemented.
	# See: "res://docs/decisions/inventory_overlay.md"
	#print("InventoryOverlay: rotation is not yet implemented")
	#get_viewport().set_input_as_handled()


## Resolves a drop attempt at the current footprint position.
##
## If the footprint hasn't moved from the item's origin, treats confirm as a
## cancel — the item stays in place without the player needing the dedicated
## cancel key. This is intentional UX, not in the spec.
func _on_drop() -> void:
	var held: ItemState = _sm.selected_snapshot
	var to_pos: Vector2i = _sm.cursor_cell

	# Footprint hasn't moved — confirm on the origin cell is treated as a cancel.
	# This lets the player "put it back" without pressing the dedicated cancel key.
	if to_pos == held.position:
		_sm.go_to_browse()
		return

	# Clamping in handle_input must have kept the footprint in bounds — crash if it did not.
	(
		Utils
		. require(
			(
				to_pos.x >= 0
				and to_pos.y >= 0
				and to_pos.x + held.data.inventory_size.x <= PlayerInventory.grid_size.x
				and to_pos.y + held.data.inventory_size.y <= PlayerInventory.grid_size.y
			),
			(
				"MoveState._on_drop: footprint %s out of bounds — cursor clamping should prevent this"
				% to_pos
			),
		)
	)

	if PlayerInventory.can_move_item(held.position, to_pos):
		PlayerInventory.move_item(held.position, to_pos)
		_sm.overlay.refresh_slots()
		_sm.go_to_browse()
		return

	# Footprint is blocked. Find the single interactable item under the footprint
	# (excluding the held item itself). If multiple items overlap, no interaction applies.
	var target: ItemState = _find_unique_target(held, to_pos)
	if target == null:
		# Two or more distinct items under the footprint — no interaction applies.
		print("InventoryOverlay: cannot drop '%s' here" % held.data.ui_name)
		return

	_try_drop_onto_occupied(held, target)


## Attempts the three occupied-cell interactions (stack merge, weapon upgrade, recipe combine)
## in spec order. Prints feedback and stays in Move state if none apply.
func _try_drop_onto_occupied(held: ItemState, target: ItemState) -> void:
	# Stack merge — same item type, stackable, and target has enough capacity for all held units.
	if (
		held.data.id == target.data.id
		and held.data.is_stackable()
		and (target.data.stack_size - target.stack_count) >= held.stack_count
	):
		# add_to_stack fills the destination stack (target.position); remove_item_at then
		# removes the held item from its original grid position (held.position). The two
		# positions are intentionally different — this is the merge, not a self-remove.
		var overflow: int = PlayerInventory.add_to_stack(
			held.data.id, target.position, held.stack_count
		)
		(
			Utils
			. require(
				overflow == 0,
				(
					"MoveState._try_drop_onto_occupied: unexpected overflow %d merging '%s'"
					% [overflow, held.data.id]
				),
			)
		)
		PlayerInventory.remove_item_at(held.position)
		_sm.overlay.refresh_slots()
		_sm.go_to_browse()
		return

	# Weapon upgrade — held is WEAPON_UPGRADE, target is WEAPON.
	if held.data.type == ItemData.Type.WEAPON_UPGRADE and target.data.type == ItemData.Type.WEAPON:
		if not PlayerInventory.can_upgrade_weapon(target.position, held.position):
			# Weapon stat is already at maximum — reject with specific feedback.
			# TODO: play disabled-action SFX and show "weapon is maxed" toast.
			print("InventoryOverlay: weapon '%s' is already at maximum" % target.data.ui_name)
			return
		PlayerInventory.upgrade_weapon(target.position, held.position)
		_sm.overlay.refresh_slots()
		_sm.go_to_browse()
		return

	# Recipe combine — held and target IDs match a registered recipe.
	if PlayerInventory.can_combine_items(held.position, target.position):
		PlayerInventory.combine_items(held.position, target.position)
		_sm.overlay.refresh_slots()
		_sm.go_to_browse()
		return

	# No outcome — stay in Move state.
	print("InventoryOverlay: cannot drop '%s' onto '%s'" % [held.data.ui_name, target.data.ui_name])


## Returns the single non-held slot whose footprint overlaps [param to_pos],
## or [code]null[/code] if multiple distinct items overlap (ambiguous destination).
##
## Precondition: [method PlayerInventory.can_move_item] returned [code]false[/code] for
## [param to_pos], so the footprint is guaranteed to overlap at least one item.
func _find_unique_target(held: ItemState, to_pos: Vector2i) -> ItemState:
	var target: ItemState = null
	for y: int in held.data.inventory_size.y:
		for x: int in held.data.inventory_size.x:
			var slot: ItemState = PlayerInventory.get_slot_at(to_pos + Vector2i(x, y))
			# Skip empty cells and cells that belong to the held item itself. When the
			# footprint partially overlaps the item's current position (e.g. a 2×2 item
			# shifted one cell), those shared cells return the held item — filtering them
			# here ensures only genuinely different items are considered as targets.
			if slot == null or slot.position == held.position:
				continue
			if target == null:
				target = slot
			elif target.position != slot.position:
				# Footprint overlaps two or more different items — reject.
				return null
	(
		Utils
		. require(
			target != null,
			(
				(
					"MoveState._find_unique_target: no blocking item found at %s"
					+ " — can_move_item precondition violated"
				)
				% to_pos
			),
		)
	)
	return target
