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

## Fill colour used to draw each item's footprint.
const _ITEM_COLOR: Color = Color(0.2, 0.8, 0.4, 0.6)

## Fill colour for the single-cell cursor in Browse state.
const _CURSOR_COLOR: Color = Color(1.0, 1.0, 1.0, 0.35)

## Snapshots of the inventory slots captured each time the overlay opens or after a mutation.
var _slots: Array[ItemState] = []

@onready var _grid: PanelContainer = $Grid
@onready var _sm: InventoryStateMachine = $InventoryStateMachine
@onready var _action_menu_container: NinePatchRect = $ActionMenuContainer
@onready var _action_menu_cursor: Sprite2D = $ActionMenuContainer/ActionMenuCursor
@onready var _use: NinePatchRect = $ActionMenuContainer/Use
@onready var _move: NinePatchRect = $ActionMenuContainer/Move
@onready var _examine: NinePatchRect = $ActionMenuContainer/Examine
@onready var _discard: NinePatchRect = $ActionMenuContainer/Discard


func _ready() -> void:
	# Render the grid panel behind this node so item rectangles drawn via _draw
	# appear on top of the panel background.
	_grid.show_behind_parent = true
	_action_menu_container.hide()
	_sm.start()


func _on_close() -> void:
	# Reset to Browse so cursor and selection state are clean on the next open.
	if _sm.can_reset():
		_sm.reset()


func _hydrate_ui() -> void:
	refresh_slots()


func _draw() -> void:
	_draw_item_footprints()
	if _sm.current_state == _sm.browse:
		_draw_browse_cursor()
	elif _sm.current_state == _sm.action_menu:
		_draw_selected_item_highlight()
	elif _sm.current_state == _sm.move:
		_draw_move_footprint()
	# ExamineState: no extra drawing — item details are printed to console.


## Shows the action menu container, anchors it to the selected item's top-left,
## clamped so it stays within the viewport, then positions the cursor at [param index].
func show_action_menu(index: int) -> void:
	var item_top_left: Vector2 = _grid.position + Vector2(_sm.selected_snapshot.position) * _CELL_PX
	var viewport_size: Vector2 = get_viewport_rect().size
	_action_menu_container.position = Vector2(
		clampf(item_top_left.x, 0.0, viewport_size.x - _action_menu_container.size.x),
		clampf(item_top_left.y, 0.0, viewport_size.y - _action_menu_container.size.y),
	)
	_action_menu_container.show()
	update_action_cursor(index)


## Hides the action menu container.
func hide_action_menu() -> void:
	_action_menu_container.hide()


## Moves the cursor sprite to align with the action at [param index] and schedules a redraw.
func update_action_cursor(index: int) -> void:
	var actions: Array[NinePatchRect] = [_use, _move, _examine, _discard]
	_action_menu_cursor.position.y = actions[index].position.y
	queue_redraw()


## Refreshes [member _slots] from [PlayerInventory], resizes the grid panel, and schedules a redraw.
##
## Call this after every successful inventory mutation so [member _slots],
## the grid dimensions, and the drawn footprints all reflect the updated state.
## Resizing is included here so grid upgrades (INVENTORY_UPGRADE items) are
## reflected immediately without a separate call.
func refresh_slots() -> void:
	_slots = PlayerInventory.get_slots()
	var gs: Vector2i = PlayerInventory.grid_size
	_grid.size = Vector2(gs.x * _CELL_PX, gs.y * _CELL_PX)
	queue_redraw()


func _draw_item_footprints() -> void:
	var grid_origin: Vector2 = _grid.position
	for slot: ItemState in _slots:
		draw_rect(
			Rect2(
				grid_origin + Vector2(slot.position) * _CELL_PX,
				Vector2(slot.data.inventory_size) * _CELL_PX,
			),
			_ITEM_COLOR,
		)


func _draw_browse_cursor() -> void:
	var grid_origin: Vector2 = _grid.position
	draw_rect(
		Rect2(
			grid_origin + Vector2(_sm.cursor_cell) * _CELL_PX,
			Vector2(_CELL_PX, _CELL_PX),
		),
		_CURSOR_COLOR,
	)


func _draw_selected_item_highlight() -> void:
	var grid_origin: Vector2 = _grid.position
	var snapshot: ItemState = _sm.selected_snapshot
	draw_rect(
		Rect2(
			grid_origin + Vector2(snapshot.position) * _CELL_PX,
			Vector2(snapshot.data.inventory_size) * _CELL_PX,
		),
		_CURSOR_COLOR,
	)


func _draw_move_footprint() -> void:
	var grid_origin: Vector2 = _grid.position
	var snapshot: ItemState = _sm.selected_snapshot
	var to_pos: Vector2i = _sm.cursor_cell
	var color: Color = _CURSOR_COLOR
	draw_rect(
		Rect2(
			grid_origin + Vector2(to_pos) * _CELL_PX,
			Vector2(snapshot.data.inventory_size) * _CELL_PX,
		),
		color,
	)
