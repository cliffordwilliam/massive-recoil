class_name InventoryBrowseState
extends InventoryBaseState
## Browse state for [InventoryStateMachine].
##
## Default state. The cursor snaps to the top-left corner of any item it
## overlaps and expands to cover the item's full footprint. Movement keys shift
## the cursor one cell; when leaving an item the cursor is pushed past the
## item's far edge in the movement direction before snapping to any item at the
## new cell. Pressing confirm on an occupied cell transitions to [InventoryActionMenuState].


func enter(old_state: BaseState) -> void:
	# Reset cursor to origin only on initial entry (overlay first opened or SM reset).
	# Preserve cursor position when returning from ActionMenu, Move, or Examine so the
	# player's place in the grid is not lost mid-session.
	if old_state == null:
		_sm.cursor_cell = Vector2i.ZERO
	# If the cursor already overlaps an item (e.g. a new item was placed under it
	# while in another state), snap it to that item's top-left immediately.
	var slot: ItemState = PlayerInventory.get_slot_at(_sm.cursor_cell)
	if slot != null:
		_sm.cursor_cell = slot.position
	_sm.overlay.queue_redraw()


func handle_input(event: InputEvent) -> void:
	var dir_x: int = Utils.get_axis(event, InputActions.LEFT, InputActions.RIGHT)
	var dir_y: int = Utils.get_axis(event, InputActions.UP, InputActions.DOWN)
	if dir_x != 0 or dir_y != 0:
		var new_pos: Vector2i = _compute_new_cursor_pos(dir_x, dir_y)
		if new_pos != _sm.cursor_cell:
			_sm.cursor_cell = new_pos
			_sm.overlay.queue_redraw()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(InputActions.ACCEPT):
		_on_confirm()
		get_viewport().set_input_as_handled()


func draw() -> void:
	_sm.overlay.draw_item_footprints()
	_sm.overlay.draw_browse_cursor()


func _on_confirm() -> void:
	var slot: ItemState = PlayerInventory.get_slot_at(_sm.cursor_cell)
	if slot == null:
		return
	_sm.go_to_action_menu(slot)


func _compute_new_cursor_pos(dir_x: int, dir_y: int) -> Vector2i:
	var current: Vector2i = _sm.cursor_cell
	var gs: Vector2i = PlayerInventory.grid_size
	var current_slot: ItemState = PlayerInventory.get_slot_at(current)
	# Snap the origin to the item's top-left before computing the candidate,
	# so push logic is always relative to the item's corner regardless of
	# where in the item the cursor physically sits.
	var origin: Vector2i = current_slot.position if current_slot != null else current
	var new_pos: Vector2i = origin + Vector2i(dir_x, dir_y)
	if current_slot != null:
		var item_tl: Vector2i = current_slot.position
		var item_br: Vector2i = item_tl + current_slot.data.inventory_size
		var inside_x: bool = new_pos.x >= item_tl.x and new_pos.x < item_br.x
		var inside_y: bool = new_pos.y >= item_tl.y and new_pos.y < item_br.y
		if inside_x and inside_y:
			if dir_x > 0:
				new_pos.x = item_br.x
			elif dir_x < 0:
				new_pos.x = item_tl.x - 1
			if dir_y > 0:
				new_pos.y = item_br.y
			elif dir_y < 0:
				new_pos.y = item_tl.y - 1
	new_pos.x = clampi(new_pos.x, 0, gs.x - 1)
	new_pos.y = clampi(new_pos.y, 0, gs.y - 1)
	# Snap to item top-left if the new cell overlaps any item.
	var target_slot: ItemState = PlayerInventory.get_slot_at(new_pos)
	if target_slot != null:
		new_pos = target_slot.position
	return new_pos
