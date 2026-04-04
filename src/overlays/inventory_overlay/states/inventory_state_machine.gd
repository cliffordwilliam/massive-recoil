class_name InventoryStateMachine
extends StateMachine
## Concrete state machine for [InventoryOverlay].
##
## Holds shared cursor and selection state that persists across state transitions.
## Each inventory state extends [InventoryBaseState], which exposes a typed
## [member InventoryBaseState._sm] reference and named transition methods on this machine.

## Current cursor position in grid cell coordinates.
##
## In [InventoryBrowseState]: the highlighted single cell.
## In [InventoryMoveState]: the top-left corner of the held item's footprint.
var cursor_cell: Vector2i = Vector2i.ZERO

## Item selected in [InventoryBrowseState], passed to action/move/examine states.
## [code]null[/code] while in [InventoryBrowseState] or before any state has been entered.
var selected_snapshot: ItemState = null

@onready var overlay: InventoryOverlay = get_parent() as InventoryOverlay
@onready var browse: InventoryBrowseState = $InventoryBrowseState
@onready var action_menu: InventoryActionMenuState = $InventoryActionMenuState
@onready var move: InventoryMoveState = $InventoryMoveState
@onready var examine: InventoryExamineState = $InventoryExamineState


func _ready() -> void:
	await super()


func go_to_browse() -> void:
	selected_snapshot = null
	transition_to(browse)


func go_to_action_menu(snapshot: ItemState) -> void:
	selected_snapshot = snapshot
	transition_to(action_menu)


func go_to_move() -> void:
	transition_to(move)


func go_to_examine() -> void:
	transition_to(examine)
