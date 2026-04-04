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

## Pixel size of one inventory cell. All draw coordinates are in this unit.
const _CELL_PX: int = 16

## Fill colour for the single-cell cursor in Browse state.
const _CURSOR_COLOR: Color = Color(1.0, 1.0, 1.0, 0.35)

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


func _ready() -> void:
	_grid.show_behind_parent = true
	hide_action_menu()
	action_menu.bind(use, func() -> void: use_item())
	action_menu.bind(move, func() -> void: _sm.go_to_move())
	action_menu.bind(examine, func() -> void: _sm.go_to_examine())
	action_menu.bind(discard, func() -> void: discard_item())


func _draw() -> void:
	_sm.draw_state()


## Shows the action menu anchored to the selected item's top-right corner,
## clamped so it stays within the viewport, and resets the cursor to the first action.
func show_action_menu() -> void:
	var slot: ItemState = _sm.selected_snapshot
	var item_top_right: Vector2 = (
		_grid.position
		+ (Vector2(slot.position.x + slot.data.inventory_size.x, slot.position.y) * _CELL_PX)
	)
	var viewport_size: Vector2 = get_viewport_rect().size
	action_menu.position = Vector2(
		clampf(item_top_right.x, 0.0, viewport_size.x - action_menu.size.x),
		clampf(item_top_right.y, 0.0, viewport_size.y - action_menu.size.y),
	)
	action_menu.visible = true


func hide_action_menu() -> void:
	action_menu.visible = false


## Executes the Use action for the selected item.
## Types with no use effect stay in [InventoryActionMenuState].
func use_item() -> void:
	# TODO: disable the Use button in the UI for types with no use effect.
	var slot: ItemState = _sm.selected_snapshot
	match slot.data.type:
		ItemData.Type.MED:
			PlayerInventory.remove_item_at(slot.position)
			# TODO: apply healing effect to player health.
			refresh_slots()
			_sm.go_to_browse()
		ItemData.Type.INVENTORY_UPGRADE:
			if not PlayerInventory.upgrade_grid():
				return
			PlayerInventory.remove_item_at(slot.position)
			refresh_slots()
			_sm.go_to_browse()
		ItemData.Type.WEAPON:
			# TODO: call the equip API on GameState when it exists.
			_sm.go_to_browse()


## Permanently removes the selected item from the inventory and returns to [InventoryBrowseState].
func discard_item() -> void:
	# TODO: call the unequip API on GameState when it exists.
	var slot: ItemState = _sm.selected_snapshot
	PlayerInventory.remove_item_at(slot.position)
	refresh_slots()
	_sm.go_to_browse()


## Refreshes [member _slots] from [PlayerInventory], resizes the grid panel, and schedules a redraw.
##
## Call this after every successful inventory mutation so [member _slots],
## the grid dimensions, and the drawn footprints all reflect the updated state.
func refresh_slots() -> void:
	_slots = PlayerInventory.get_slots()
	_slot_textures.clear()
	for slot: ItemState in _slots:
		_slot_textures[slot.position] = slot.data.slot_texture
	var gs: Vector2i = PlayerInventory.grid_size
	_grid.size = Vector2(gs.x * _CELL_PX, gs.y * _CELL_PX)
	queue_redraw()


## Draws the browse cursor at [member InventoryStateMachine.cursor_cell].
## Expands to cover the full item footprint when the cursor is snapped to an item;
## otherwise draws a single cell.
func draw_browse_cursor() -> void:
	var grid_origin: Vector2 = _grid.position
	var cursor_size: Vector2i = Vector2i.ONE
	var slot: ItemState = PlayerInventory.get_slot_at(_sm.cursor_cell)
	if slot != null:
		cursor_size = slot.data.inventory_size
	draw_rect(
		Rect2(
			grid_origin + Vector2(_sm.cursor_cell) * _CELL_PX,
			Vector2(cursor_size) * _CELL_PX,
		),
		_CURSOR_COLOR,
	)


## Draws the held item's texture at the current cursor position,
## then overlays a highlight rect covering its full footprint.
func draw_move_footprint() -> void:
	var grid_origin: Vector2 = _grid.position
	var slot: ItemState = _sm.selected_snapshot
	var cursor_origin: Vector2 = grid_origin + Vector2(_sm.cursor_cell) * _CELL_PX
	draw_texture(_slot_textures[slot.position], cursor_origin)
	draw_rect(
		Rect2(cursor_origin, Vector2(slot.data.inventory_size) * _CELL_PX),
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


func _on_close() -> void:
	# Reset to Browse so cursor and selection state are clean on the next open.
	_sm.reset()


func _hydrate_ui() -> void:
	var gs: Vector2i = PlayerInventory.grid_size
	_sm.cursor_cell = _sm.cursor_cell.clamp(Vector2i.ZERO, gs - Vector2i.ONE)
	refresh_slots()
