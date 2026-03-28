class_name InventoryStateMachine
extends StateMachine
## Concrete state machine for [InventoryOverlay].
##
## Holds shared cursor and selection state that persists across state transitions.
## Each inventory state extends [InventoryBaseState], which exposes a typed
## [member InventoryBaseState._sm] reference and named transition methods on this machine.
##
## See: "res://docs/decisions/inventory_overlay.md"

## Current cursor position in grid cell coordinates.
##
## In [InventoryBrowseState]: the highlighted single cell.
## In [InventoryMoveState]: the top-left corner of the held item's footprint.
var cursor_cell: Vector2i = Vector2i.ZERO

## Snapshot of the item selected in [BrowseState].
##
## Set before transitioning to [InventoryActionMenuState], [InventoryMoveState], or
## [InventoryExamineState].
## [code]null[/code] while in [InventoryBrowseState] or before any state has been entered.
var selected_snapshot: ItemState = null

## Typed reference to the parent [InventoryOverlay].
@onready var overlay: InventoryOverlay = get_parent() as InventoryOverlay

## Browse state child node.
@onready var browse: InventoryBrowseState = $InventoryBrowseState

## Action menu state child node.
@onready var action_menu: InventoryActionMenuState = $InventoryActionMenuState

## Move state child node.
@onready var move: InventoryMoveState = $InventoryMoveState

## Examine state child node.
@onready var examine: InventoryExamineState = $InventoryExamineState


## Waits for [StateMachine._ready] to finish entering [member StateMachine.initial_state],
## then asserts the parent is an [InventoryOverlay].
##
## [StateMachine._ready] is a coroutine that awaits the parent's [signal Node.ready] signal
## before entering the initial state. Using [code]await super()[/code] here ensures this
## [method Node._ready] does not return until that sequence is fully complete.
func _ready() -> void:
	await super()
	(
		Utils
		. require(
			overlay is InventoryOverlay,
			"InventoryStateMachine._ready: parent must be an InventoryOverlay",
		)
	)


## Clears [member selected_snapshot] and transitions to [InventoryBrowseState].
func go_to_browse() -> void:
	selected_snapshot = null
	transition_to(browse)


## Sets [member selected_snapshot] to [param snapshot] and transitions to
## [InventoryActionMenuState].
func go_to_action_menu(snapshot: ItemState) -> void:
	selected_snapshot = snapshot
	transition_to(action_menu)


## Transitions to [InventoryMoveState].
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
	transition_to(move)


## Transitions to [InventoryExamineState].
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
	transition_to(examine)
