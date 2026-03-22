class_name ExamineState
extends BaseState
## Examine state for [InventoryStateMachine].
##
## Shows a detail view for the selected item. The only valid action is Close,
## which returns to [BrowseState].
##
## Modal rendering is not yet implemented. Item details are printed to the console
## as a placeholder.
##
## See: "res://docs/decisions/inventory_overlay.md"

@onready var _sm: InventoryStateMachine = state_machine as InventoryStateMachine


## Prints item details to the console as a placeholder for the modal UI.
func enter(_old_state: StringName) -> void:
	_print_item_details()
	_sm.overlay.queue_redraw()


## No-op until the examine modal UI is implemented.
##
## TODO: call the overlay method that hides the modal UI when it is implemented.
func exit() -> void:
	pass


## Closes the examine view on accept or cancel, returning to [BrowseState].
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") or event.is_action_pressed("cancel"):
		_sm.go_to_browse()
		get_viewport().set_input_as_handled()


func _print_item_details() -> void:
	var snapshot: ItemState = _sm.selected_snapshot
	print("=== %s ===" % snapshot.data.ui_name)
	print(snapshot.data.description)
	if snapshot.data.type == ItemData.Type.WEAPON:
		var stats: WeaponStatsState = snapshot.weapon_stats_state
		var wd: WeaponData = snapshot.data.weapon_data
		print("Power:        %d / %d" % [stats.power, wd.power_max])
		print("Rate of Fire: %d / %d" % [stats.rate_of_fire, wd.rate_of_fire_max])
		print("Reload Speed: %d / %d" % [stats.reload_speed, wd.reload_speed_max])
		print("Ammo Cap:     %d / %d" % [stats.ammo_capacity, wd.ammo_capacity_max])
