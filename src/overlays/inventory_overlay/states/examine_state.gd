class_name InventoryExamineState
extends InventoryBaseState
## Examine state for [InventoryStateMachine].
##
## Shows a detail view for the selected item. The only valid action is Close,
## which returns to [BrowseState].
##
## Modal rendering is not yet implemented. Item details are printed to the console
## as a placeholder.


func enter(_old_state: BaseState) -> void:
	_print_item_details()
	_sm.overlay.queue_redraw()


func exit() -> void:
	pass  # TODO: hide the examine modal when implemented.


func draw() -> void:
	_sm.overlay.draw_item_footprints()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(InputActions.ACCEPT) or event.is_action_pressed(InputActions.CANCEL):
		_sm.go_to_browse()
		get_viewport().set_input_as_handled()


func _print_item_details() -> void:
	var slot: ItemState = _sm.selected_snapshot
	print("=== %s ===" % slot.data.ui_name)
	print(slot.data.description)
	if slot.data.type == ItemData.Type.WEAPON:
		var ptr: WeaponPointer = slot.weapon_pointer
		var track: WeaponTrack = slot.data.weapon_track
		print("Power:        %d / %d" % [ptr.power, track.power.range_max])
		print("Rate of Fire: %d / %d" % [ptr.rate_of_fire, track.rate_of_fire.range_max])
		print("Reload Speed: %d / %d" % [ptr.reload_speed, track.reload_speed.range_max])
		print("Ammo Cap:     %d / %d" % [ptr.ammo_capacity, track.ammo_capacity.range_max])
