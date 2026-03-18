# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the OverlayRouter autoload
extends CanvasLayer
## Manages all full-screen overlays for the duration of the game session.
##
## At most one [BaseOverlay] child is active at a time. Opening an overlay
## while another overlay is already open is ignored.
## The game tree is paused while an overlay is open and unpaused on close.
##
## Uses [constant Node.PROCESS_MODE_ALWAYS] so input is received even while the
## tree is paused. Each overlay child uses [constant Node.PROCESS_MODE_DISABLED]
## when inactive, controlled via [member BaseOverlay.is_active].
##
## See: "res://docs/decisions/overlay_router.md"

## The currently open overlay, or [code]null[/code] when no overlay is active.
## All open/close logic checks this first to enforce the "at most one overlay" invariant.
var _current_overlay: BaseOverlay = null

@onready var _buy_overlay: BuyOverlay = $BuyOverlay
@onready var _inventory_overlay: InventoryOverlay = $InventoryOverlay


func _ready() -> void:
	# PROCESS_MODE_ALWAYS is intentional — not PROCESS_MODE_WHEN_PAUSED.
	# The player can press "inventory" during live gameplay (game not yet paused),
	# so this node must process input before any pause is set. Switching to
	# PROCESS_MODE_WHEN_PAUSED would silently drop that initial keypress.
	process_mode = Node.PROCESS_MODE_ALWAYS

	for child: Node in get_children():
		var entry: BaseOverlay = child as BaseOverlay
		Utils.require(entry != null, "OverlayRouter: child '%s' is not a BaseOverlay" % child.name)
		entry.is_active = false


## Input is handled here for actions that control overlay routing.
##
## [code]pause[/code] closes the current overlay from anywhere.
##
## Open other overlays only when none is currently open.
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and _current_overlay:
		_close_overlay()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("inventory") and _current_overlay == null:
		open_inventory_overlay()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("buy") and _current_overlay == null:
		open_buy_overlay()
		get_viewport().set_input_as_handled()

	# Once any overlay is open, the only valid action is closing it (via cancel).
	elif (
		(event.is_action_pressed("inventory") or event.is_action_pressed("buy"))
		and _current_overlay
	):
		get_viewport().set_input_as_handled()


## Opens the shop buy overlay.
##
## If an overlay is already open, this request is ignored.
## See: "res://docs/decisions/overlay_router.md"
func open_buy_overlay() -> void:
	if _current_overlay:
		return
	_open_overlay(_buy_overlay)


## Opens the inventory overlay.
##
## If an overlay is already open, this request is ignored.
## See: "res://docs/decisions/overlay_router.md"
func open_inventory_overlay() -> void:
	if _current_overlay:
		return
	_open_overlay(_inventory_overlay)


## Closes the currently open overlay and unpauses the game tree.
## Only called when [member _current_overlay] is non-null — callers guard this invariant.
func _close_overlay() -> void:
	_current_overlay.is_active = false
	_current_overlay = null
	get_tree().paused = false


## Activates [param new_overlay] and pauses the tree.
## [param new_overlay] must not be null — crashes via [method Utils.require] if so.
func _open_overlay(new_overlay: BaseOverlay) -> void:
	Utils.require(new_overlay != null, "OverlayRouter._open_overlay: overlay must not be null")
	_current_overlay = new_overlay
	_current_overlay.is_active = true
	get_tree().paused = true
