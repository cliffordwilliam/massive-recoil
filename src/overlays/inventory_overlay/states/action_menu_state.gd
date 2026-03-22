class_name ActionMenuState
extends BaseState
## Action menu state for [InventoryStateMachine].
##
## Displays four context-sensitive actions for the selected item.
## Navigate up/down to focus an action; confirm executes it; cancel returns to [BrowseState].
##
## See: "res://docs/decisions/inventory_overlay.md"

## Total number of actions in the menu.
const _ACTION_COUNT: int = 4

## Index of the Use action. Context-sensitive — disabled for types with no use effect.
const _ACTION_USE: int = 0

## Index of the Move action.
const _ACTION_MOVE: int = 1

## Index of the Examine action.
const _ACTION_EXAMINE: int = 2

## Index of the Discard action.
const _ACTION_DISCARD: int = 3

## Currently focused action index. Read by [InventoryOverlay] to draw the selection highlight.
var selected_action: int = _ACTION_USE

@onready var _sm: InventoryStateMachine = state_machine as InventoryStateMachine


## Resets selection to [constant _ACTION_USE] and shows the action menu.
func enter(_old_state: StringName) -> void:
	selected_action = _ACTION_USE
	_sm.overlay.show_action_menu(selected_action)


## Hides the action menu.
func exit() -> void:
	_sm.overlay.hide_action_menu()


## Navigates the menu with up/down; confirm executes the focused action; cancel returns to
## [BrowseState].
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		selected_action = (selected_action - 1 + _ACTION_COUNT) % _ACTION_COUNT
		_sm.overlay.update_action_cursor(selected_action)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("down"):
		selected_action = (selected_action + 1) % _ACTION_COUNT
		_sm.overlay.update_action_cursor(selected_action)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("left") or event.is_action_pressed("right"):
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("accept"):
		_execute_selected_action()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cancel"):
		_sm.go_to_browse()
		get_viewport().set_input_as_handled()


func _execute_selected_action() -> void:
	match selected_action:
		_ACTION_USE:
			_try_use()
		_ACTION_MOVE:
			_sm.go_to_move()
		_ACTION_EXAMINE:
			_sm.go_to_examine()
		_ACTION_DISCARD:
			_discard()
		_:
			(
				Utils
				. require(
					false,
					(
						"ActionMenuState._execute_selected_action: unhandled action %d"
						% selected_action
					),
				)
			)


func _try_use() -> void:
	# TODO: disable the Use button in the UI for types with no use effect rather than
	# executing and printing feedback. The spec says the button should be visually
	# disabled — this requires the overlay to know the selected item's type when
	# building the action menu. See: "res://docs/decisions/inventory_overlay.md"
	var snapshot: ItemState = _sm.selected_snapshot
	match snapshot.data.type:
		ItemData.Type.MED:
			PlayerInventory.remove_item_at(snapshot.position)
			# TODO: apply healing effect to player health
			print("InventoryOverlay: used MED item '%s'" % snapshot.data.ui_name)
			_sm.overlay.refresh_slots()
			_sm.go_to_browse()
		ItemData.Type.INVENTORY_UPGRADE:
			if not PlayerInventory.can_upgrade_grid():
				print("InventoryOverlay: inventory is already at maximum size")
				return
			PlayerInventory.remove_item_at(snapshot.position)
			PlayerInventory.upgrade_grid()
			print("InventoryOverlay: inventory expanded")
			_sm.overlay.refresh_slots()
			_sm.go_to_browse()
		ItemData.Type.WEAPON:
			# Equip without removing from inventory. Returns to Browse.
			# TODO: call the equip API on GameState or equivalent when it exists
			print("InventoryOverlay: equipped weapon '%s'" % snapshot.data.ui_name)
			_sm.go_to_browse()
		_:
			# Intentional — item has no use effect. Stay in ActionMenuState.
			# The Use button will be visually disabled once the overlay knows the
			# item's type at menu build time. See: "res://docs/decisions/inventory_overlay.md"
			print("InventoryOverlay: '%s' has no use action" % snapshot.data.ui_name)


func _discard() -> void:
	# Discard is unconditional. If the item is currently equipped, discarding it
	# unequips it first and then removes it from the inventory permanently.
	# TODO: call the unequip API on GameState or equivalent when it exists.
	var snapshot: ItemState = _sm.selected_snapshot
	PlayerInventory.remove_item_at(snapshot.position)
	_sm.overlay.refresh_slots()
	_sm.go_to_browse()
