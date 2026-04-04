class_name InventoryExamineState
extends InventoryBaseState
## Examine state for [InventoryStateMachine].
##
## Shows a detail view for the selected item. The only valid action is Close,
## which returns to [BrowseState].


func enter(_old_state: BaseState) -> void:
	_sm.overlay.show_detail(_sm.selected_snapshot)
	_sm.overlay.queue_redraw()


func exit() -> void:
	_sm.overlay.hide_detail()


func draw() -> void:
	_sm.overlay.draw_item_footprints()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(InputActions.ACCEPT) or event.is_action_pressed(InputActions.CANCEL):
		_sm.go_to_browse()
		get_viewport().set_input_as_handled()
