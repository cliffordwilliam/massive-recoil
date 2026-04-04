# OverlayRouter autoload
extends CanvasLayer
## Manages all full-screen overlays for the duration of the game session.
##
## At most one [BaseOverlay] child is active at a time. Opening an overlay
## while another overlay is already open is ignored.
## The game tree is paused while an overlay is open and unpaused on close.
##
## See: "res://docs/decisions/overlay_router.md"

var _current_overlay: BaseOverlay = null

# All game overlay goes here.
@onready var _buy_overlay: BuyOverlay = $BuyOverlay
@onready var _inventory_overlay: InventoryOverlay = $InventoryOverlay


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child: Node in get_children():
		(child as BaseOverlay).is_active = false


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(InputActions.CANCEL) and _current_overlay:
		_current_overlay.is_active = false
		_current_overlay = null
		get_tree().paused = false
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(InputActions.INVENTORY):
		open_inventory_overlay()

	elif event.is_action_pressed(InputActions.BUY):
		open_buy_overlay()


func open_buy_overlay() -> void:
	_open_overlay(_buy_overlay)


func open_inventory_overlay() -> void:
	_open_overlay(_inventory_overlay)


func _open_overlay(new_overlay: BaseOverlay) -> void:
	get_viewport().set_input_as_handled()
	if _current_overlay:
		return
	get_tree().paused = true
	_current_overlay = new_overlay
	_current_overlay.is_active = true
