class_name InventoryActionMenuState
extends InventoryBaseState
## Action menu state for [InventoryStateMachine].
##
## Displays four context-sensitive actions for the selected item.
## Navigate up/down to focus an action; confirm executes it; cancel returns to
## [InventoryBrowseState].


func enter(_old_state: BaseState) -> void:
	_sm.overlay.show_action_menu()


func exit() -> void:
	_sm.overlay.hide_action_menu()


func draw() -> void:
	_sm.overlay.draw_item_footprints()


func handle_input(event: InputEvent) -> void:
	var dir_x: int = Utils.get_axis(event, InputActions.LEFT, InputActions.RIGHT)
	var dir_y: int = Utils.get_axis(event, InputActions.UP, InputActions.DOWN)
	if dir_x != 0 or dir_y != 0:
		if dir_y == 1:
			_sm.overlay._action_menu.select_next()
		elif dir_y == -1:
			_sm.overlay._action_menu.select_previous()
		# Left/right are consumed without effect in the action menu.
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(InputActions.CANCEL):
		_sm.go_to_browse()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(InputActions.ACCEPT):
		_sm.overlay._action_menu.confirm()
		get_viewport().set_input_as_handled()
