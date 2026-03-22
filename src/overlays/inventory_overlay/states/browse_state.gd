class_name BrowseState
extends BaseState
## Browse state for [InventoryStateMachine].
##
## Default state. The cursor is a single highlighted cell that moves one cell
## at a time with the movement keys. Pressing confirm on an occupied cell
## transitions to [ActionMenuState] for that item.
##
## See: "res://docs/decisions/inventory_overlay.md"

@onready var _sm: InventoryStateMachine = state_machine as InventoryStateMachine


## Resets cursor to origin on first entry; preserves position on re-entry from other states.
func enter(old_state: StringName) -> void:
	# Reset cursor to origin only on initial entry (overlay first opened or SM reset).
	# Preserve cursor position when returning from ActionMenu, Move, or Examine so the
	# player's place in the grid is not lost mid-session.
	if old_state == &"":
		_sm.cursor_cell = Vector2i.ZERO
	_sm.overlay.queue_redraw()


## Moves the cursor with movement keys; confirms selection on an occupied cell.
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		var new_y: int = max(0, _sm.cursor_cell.y - 1)
		if new_y != _sm.cursor_cell.y:
			_sm.cursor_cell.y = new_y
			_sm.overlay.queue_redraw()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("down"):
		var new_y: int = min(PlayerInventory.grid_size.y - 1, _sm.cursor_cell.y + 1)
		if new_y != _sm.cursor_cell.y:
			_sm.cursor_cell.y = new_y
			_sm.overlay.queue_redraw()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("left"):
		var new_x: int = max(0, _sm.cursor_cell.x - 1)
		if new_x != _sm.cursor_cell.x:
			_sm.cursor_cell.x = new_x
			_sm.overlay.queue_redraw()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("right"):
		var new_x: int = min(PlayerInventory.grid_size.x - 1, _sm.cursor_cell.x + 1)
		if new_x != _sm.cursor_cell.x:
			_sm.cursor_cell.x = new_x
			_sm.overlay.queue_redraw()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("accept"):
		_on_confirm()
		get_viewport().set_input_as_handled()


func _on_confirm() -> void:
	var snapshot: ItemState = PlayerInventory.get_slot_at(_sm.cursor_cell)
	if snapshot == null:
		return
	_sm.go_to_action_menu(snapshot)
