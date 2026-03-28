class_name InventoryBrowseState
extends InventoryBaseState
## Browse state for [InventoryStateMachine].
##
## Default state. The cursor is a single highlighted cell that moves one cell
## at a time with the movement keys. Pressing confirm on an occupied cell
## transitions to [InventoryActionMenuState] for that item.
##
## See: "res://docs/decisions/inventory_overlay.md"


## Resets cursor to origin on first entry; preserves position on re-entry from other states.
func enter(old_state: BaseState) -> void:
	# Reset cursor to origin only on initial entry (overlay first opened or SM reset).
	# Preserve cursor position when returning from ActionMenu, Move, or Examine so the
	# player's place in the grid is not lost mid-session.
	if old_state == null:
		_sm.cursor_cell = Vector2i.ZERO
	_sm.overlay.queue_redraw()


## Moves the cursor with movement keys; confirms selection on an occupied cell.
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
		var new_x: int = clampi(_sm.cursor_cell.x + dir_x, 0, PlayerInventory.grid_size.x - 1)
		var new_y: int = clampi(_sm.cursor_cell.y + dir_y, 0, PlayerInventory.grid_size.y - 1)
		if new_x != _sm.cursor_cell.x or new_y != _sm.cursor_cell.y:
			_sm.cursor_cell = Vector2i(new_x, new_y)
			_sm.overlay.queue_redraw()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(InputActions.ACCEPT):
		_on_confirm()
		get_viewport().set_input_as_handled()


## Draws item footprints then the browse cursor via the overlay.
func draw() -> void:
	_sm.overlay.draw_item_footprints()
	_sm.overlay.draw_browse_cursor()


## Transitions to [InventoryActionMenuState] if the cursor is on an occupied cell; no-ops otherwise.
func _on_confirm() -> void:
	var snapshot: ItemState = PlayerInventory.get_slot_at(_sm.cursor_cell)
	if snapshot == null:
		return
	_sm.go_to_action_menu(snapshot)
