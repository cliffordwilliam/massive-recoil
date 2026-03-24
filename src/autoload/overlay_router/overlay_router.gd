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
## tree is paused. PROCESS_MODE_ALWAYS is intentional — not PROCESS_MODE_WHEN_PAUSED.
## The player can press "inventory" during live gameplay (game not yet paused),
## so this node must process input before any pause is set. Switching to
## PROCESS_MODE_WHEN_PAUSED would silently drop that initial keypress.
## Each overlay child uses [constant Node.PROCESS_MODE_DISABLED]
## when inactive, controlled via [member BaseOverlay.is_active].
##
## See: "res://docs/decisions/overlay_router.md"

## The currently open overlay, or [code]null[/code] when no overlay is active.
## All open/close logic checks this first to enforce the "at most one overlay" invariant.
var _current_overlay: BaseOverlay = null

@onready var _buy_overlay: BuyOverlay = $BuyOverlay
@onready var _inventory_overlay: InventoryOverlay = $InventoryOverlay


## Sets [constant Node.PROCESS_MODE_ALWAYS] and deactivates all child overlays.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for child: Node in get_children():
		var entry: BaseOverlay = child as BaseOverlay
		(
			Utils
			. require(
				entry != null,
				"OverlayRouter: child '%s' is not a BaseOverlay" % child.name,
			)
		)
		entry.is_active = false


## Input is handled here for actions that control overlay routing.
##
## [code]cancel[/code] closes the current overlay from anywhere.
##
## Open other overlays only when none is currently open.
func _unhandled_key_input(event: InputEvent) -> void:
	# cancel with no active overlay is intentionally unhandled — let it propagate.
	if event.is_action_pressed(&"cancel") and _current_overlay:
		_current_overlay.is_active = false
		_current_overlay = null
		get_tree().paused = false
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(&"inventory") and _current_overlay == null:
		open_inventory_overlay()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(&"buy") and _current_overlay == null:
		open_buy_overlay()
		get_viewport().set_input_as_handled()

	# Once any overlay is open, the only valid action is closing it (via cancel).
	elif event.is_action_pressed(&"inventory") or event.is_action_pressed(&"buy"):
		get_viewport().set_input_as_handled()


## Opens the shop buy overlay.
func open_buy_overlay() -> void:
	_open_overlay(_buy_overlay)


## Opens the inventory overlay.
func open_inventory_overlay() -> void:
	_open_overlay(_inventory_overlay)


## Activates [param new_overlay] and pauses the tree.
## If an overlay is already open, this request is ignored.
## [member BaseOverlay.is_active]'s setter calls [method BaseOverlay._hydrate_ui] when set
## to [code]true[/code] — this router does not call it directly.
## See: "res://docs/decisions/overlay_router.md"
##
## No null guard: both callers pass [code]@onready[/code] vars typed to concrete
## [BaseOverlay] subclasses — null is only possible if the scene is wired incorrectly,
## which would crash at [code]@onready[/code] resolution before reaching this method.
func _open_overlay(new_overlay: BaseOverlay) -> void:
	if _current_overlay:
		return

	get_tree().paused = true
	_current_overlay = new_overlay
	_current_overlay.is_active = true
