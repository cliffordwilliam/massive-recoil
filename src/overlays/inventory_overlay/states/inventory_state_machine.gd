class_name InventoryStateMachine
extends StateMachine
## Concrete state machine for [InventoryOverlay].
##
## Holds shared cursor and selection state that persists across state transitions.
## Each child state casts [member BaseState.state_machine] to this type to access
## typed sibling references and named transition methods.
##
## See: "res://docs/decisions/inventory_overlay.md"

## Current cursor position in grid cell coordinates.
##
## In [BrowseState]: the highlighted single cell.
## In [MoveState]: the top-left corner of the held item's footprint.
var cursor_cell: Vector2i = Vector2i.ZERO

## Snapshot of the item selected in [BrowseState].
##
## Set before transitioning to [ActionMenuState], [MoveState], or [ExamineState].
## [code]null[/code] while in [BrowseState] or before any state has been entered.
var selected_snapshot: ItemState = null

## Typed reference to the parent [InventoryOverlay].
@onready var overlay: InventoryOverlay = get_parent() as InventoryOverlay

## Browse state child node.
@onready var browse: BrowseState = $BrowseState

## Action menu state child node.
@onready var action_menu: ActionMenuState = $ActionMenuState

## Move state child node.
@onready var move: MoveState = $MoveState

## Examine state child node.
@onready var examine: ExamineState = $ExamineState


func _ready() -> void:
	super()
	(
		Utils
		. require(
			overlay is InventoryOverlay,
			"InventoryStateMachine._ready: parent must be an InventoryOverlay",
		)
	)


## Clears [member selected_snapshot] and transitions to [BrowseState].
func go_to_browse() -> void:
	selected_snapshot = null
	transition_to(browse.name)


## Sets [member selected_snapshot] to [param snapshot] and transitions to [ActionMenuState].
func go_to_action_menu(snapshot: ItemState) -> void:
	selected_snapshot = snapshot
	transition_to(action_menu.name)


## Transitions to [MoveState].
##
## Crashes if [member selected_snapshot] is not already set — call [method go_to_action_menu]
## first so the item being moved is known.
func go_to_move() -> void:
	(
		Utils
		. require(
			selected_snapshot != null,
			"InventoryStateMachine.go_to_move: selected_snapshot must be set before transitioning",
		)
	)
	transition_to(move.name)


## Transitions to [ExamineState].
##
## Crashes if [member selected_snapshot] is not already set — call [method go_to_action_menu]
## first so the item being examined is known.
func go_to_examine() -> void:
	(
		Utils
		. require(
			selected_snapshot != null,
			"InventoryStateMachine.go_to_examine: selected_snapshot must be set before transitioning",
		)
	)
	transition_to(examine.name)
