class_name InventoryOverlay
extends BaseOverlay
## Overlay that displays the player's current inventory grid.
##
## On open, resizes the [member _grid] panel to match the live grid dimensions
## and redraws item footprints at their grid positions.
## Items are drawn via [method CanvasItem._draw] directly on this [Node2D].
##
## See: "res://docs/decisions/overlay_router.md"

## Pixel size of one inventory cell. All draw coordinates are in this unit.
const _CELL_PX: int = 16

## Fill colour used to draw each item's footprint.
const _ITEM_COLOR: Color = Color(0.2, 0.8, 0.4, 0.6)

## Snapshots of the inventory slots captured each time the overlay opens.
var _slots: Array[ItemState] = []

@onready var _grid: PanelContainer = $Grid


func _ready() -> void:
	# Render the grid panel behind this node so item rectangles drawn via _draw
	# appear on top of the panel background.
	_grid.show_behind_parent = true


func _on_close() -> void:
	pass


func _hydrate_ui() -> void:
	_slots = PlayerInventory.get_slots()
	var gs: Vector2i = PlayerInventory.grid_size
	_grid.size = Vector2(gs.x * _CELL_PX, gs.y * _CELL_PX)
	queue_redraw()


## Draws each item's footprint as a filled rectangle over the grid.
func _draw() -> void:
	# _grid uses fixed offset positioning (no anchors). If anchors are ever added,
	# replace this with _grid.global_position converted to local space — otherwise
	# item rectangles will silently drift away from the visual cells.
	var grid_origin: Vector2 = _grid.position
	for slot: ItemState in _slots:
		draw_rect(
			Rect2(
				grid_origin + Vector2(slot.position) * _CELL_PX,
				Vector2(slot.data.inventory_size) * _CELL_PX,
			),
			_ITEM_COLOR,
		)
