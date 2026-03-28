class_name InventoryOverlay
extends BaseOverlay
## Overlay that displays the player's current inventory grid.
##
## On open, resizes the [member _grid] panel to match the live grid dimensions
## and redraws item footprints at their grid positions.
## Items are drawn via [method CanvasItem._draw] directly on this [Node2D].
##
## An [InventoryStateMachine] child manages the four UI states (Browse, Action menu,
## Move, Examine). States call [method refresh_slots] after mutations and query
## [PlayerInventory] directly for cell lookups.
##
## See: "res://docs/decisions/inventory_overlay.md"

## Pixel size of one inventory cell. All draw coordinates are in this unit.
const _CELL_PX: int = 16

## Fill colour for the single-cell cursor in Browse state.
const _CURSOR_COLOR: Color = Color(1.0, 1.0, 1.0, 0.35)

## Snapshots of the inventory slots captured each time the overlay opens or after a mutation.
var _slots: Array[ItemState] = []

## Textures keyed by slot position, loaded once in [method refresh_slots] and reused each draw.
var _slot_textures: Dictionary[Vector2i, Texture2D] = {}

@onready var action_menu: UISimpleList = $UISimpleList
@onready var use: PanelContainer = $UISimpleList/MarginContainer/ItemContainer/Use
@onready var move: PanelContainer = $UISimpleList/MarginContainer/ItemContainer/Move
@onready var examine: PanelContainer = $UISimpleList/MarginContainer/ItemContainer/Examine
@onready var discard: PanelContainer = $UISimpleList/MarginContainer/ItemContainer/Discard
@onready var _grid: PanelContainer = $Grid
@onready var _sm: InventoryStateMachine = $InventoryStateMachine


## Sets the grid panel to render behind this node so item textures appear on top,
## then wires each action menu item to its callback once.
func _ready() -> void:
	_grid.show_behind_parent = true
	hide_action_menu()
	action_menu.bind(use, func() -> void: use_item())
	action_menu.bind(move, func() -> void: _sm.go_to_move())
	action_menu.bind(examine, func() -> void: _sm.go_to_examine())
	action_menu.bind(discard, func() -> void: discard_item())


## Delegates all drawing to the current state via [member _sm].
func _draw() -> void:
	_sm.draw_state()


## Shows the action menu anchored to the selected item's top-right corner,
## clamped so it stays within the viewport, and resets the cursor to the first action.
func show_action_menu() -> void:
	var snapshot: ItemState = _sm.selected_snapshot
	var item_top_right: Vector2 = (
		_grid.position
		+ (
			Vector2(snapshot.position.x + snapshot.data.inventory_size.x, snapshot.position.y)
			* _CELL_PX
		)
	)
	var viewport_size: Vector2 = get_viewport_rect().size
	action_menu.position = Vector2(
		clampf(item_top_right.x, 0.0, viewport_size.x - action_menu.size.x),
		clampf(item_top_right.y, 0.0, viewport_size.y - action_menu.size.y),
	)
	action_menu.visible = true


## Hides the action menu.
func hide_action_menu() -> void:
	action_menu.visible = false


## Executes the Use action for the selected item.
## Context-sensitive: each type has a distinct effect. Types with no use effect stay in this state.
## See: "res://docs/decisions/inventory_overlay.md"
func use_item() -> void:
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
			refresh_slots()
			_sm.go_to_browse()
		ItemData.Type.INVENTORY_UPGRADE:
			if not PlayerInventory.can_upgrade_grid():
				print("InventoryOverlay: inventory is already at maximum size")
				return
			PlayerInventory.remove_item_at(snapshot.position)
			PlayerInventory.upgrade_grid()
			print("InventoryOverlay: inventory expanded")
			refresh_slots()
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


## Permanently removes the selected item from the inventory and returns to [InventoryBrowseState].
func discard_item() -> void:
	# Discard is unconditional. If the item is currently equipped, discarding it
	# unequips it first and then removes it from the inventory permanently.
	# TODO: call the unequip API on GameState or equivalent when it exists.
	var snapshot: ItemState = _sm.selected_snapshot
	PlayerInventory.remove_item_at(snapshot.position)
	refresh_slots()
	_sm.go_to_browse()


## Refreshes [member _slots] from [PlayerInventory], resizes the grid panel, and schedules a redraw.
##
## Call this after every successful inventory mutation so [member _slots],
## the grid dimensions, and the drawn footprints all reflect the updated state.
## Resizing is included here so grid upgrades (INVENTORY_UPGRADE items) are
## reflected immediately without a separate call.
func refresh_slots() -> void:
	_slots = PlayerInventory.get_slots()
	_slot_textures.clear()
	for slot: ItemState in _slots:
		var texture: Texture2D = load(slot.data.slot_texture_path) as Texture2D
		Utils.require(
			texture != null,
			(
				"InventoryOverlay.refresh_slots: failed to load texture for '%s' at path '%s'"
				% [slot.data.id, slot.data.slot_texture_path]
			)
		)
		_slot_textures[slot.position] = texture
	var gs: Vector2i = PlayerInventory.grid_size
	_grid.size = Vector2(gs.x * _CELL_PX, gs.y * _CELL_PX)
	queue_redraw()


## Draws the single-cell cursor at [member InventoryStateMachine.cursor_cell].
## Called by [InventoryBrowseState.draw].
func draw_browse_cursor() -> void:
	var grid_origin: Vector2 = _grid.position
	draw_rect(
		Rect2(
			grid_origin + Vector2(_sm.cursor_cell) * _CELL_PX,
			Vector2(_CELL_PX, _CELL_PX),
		),
		_CURSOR_COLOR,
	)


## Draws the held item's texture at the current cursor position,
## then overlays a highlight rect covering its full footprint.
## Called by [InventoryMoveState.draw].
func draw_move_footprint() -> void:
	var grid_origin: Vector2 = _grid.position
	var snapshot: ItemState = _sm.selected_snapshot
	var cursor_origin: Vector2 = grid_origin + Vector2(_sm.cursor_cell) * _CELL_PX
	draw_texture(_slot_textures[snapshot.position], cursor_origin)
	draw_rect(
		Rect2(cursor_origin, Vector2(snapshot.data.inventory_size) * _CELL_PX),
		_CURSOR_COLOR,
	)


## Draws each slot's texture at its grid position.
## Pass [param skip_pos] to omit the slot at that position — used by [InventoryMoveState]
## to hide the held item while it follows the cursor.
func draw_item_footprints(skip_pos: Vector2i = Vector2i(-1, -1)) -> void:
	var grid_origin: Vector2 = _grid.position
	for pos: Vector2i in _slot_textures:
		if pos == skip_pos:
			continue
		draw_texture(_slot_textures[pos], grid_origin + Vector2(pos) * _CELL_PX)


## Resets the state machine to [InventoryBrowseState] so cursor and selection are clean on the next
## open.
func _on_close() -> void:
	# Reset to Browse so cursor and selection state are clean on the next open.
	if _sm.can_reset():
		_sm.reset()


## Refreshes slot data from [PlayerInventory] each time the overlay becomes active.
## Clamps the cursor so a grid size change between sessions never leaves it out of bounds.
func _hydrate_ui() -> void:
	var gs: Vector2i = PlayerInventory.grid_size
	_sm.cursor_cell = _sm.cursor_cell.clamp(Vector2i.ZERO, gs - Vector2i.ONE)
	refresh_slots()
