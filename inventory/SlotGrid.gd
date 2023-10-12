extends GridContainer

var start_pos: Vector2
var last_pos: Vector2
var is_clicked: bool
var clicked_inventory_item: InventoryItem
var clicked_container: CenterContainer
onready var rows: int = get_child_count()/columns

signal selection_changed

func _ready():
	connect("selection_changed", self, "_on_selection_change")
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index != 1:
			pass
		if event.pressed:
			_on_click()
		else:
			_on_release()
		pass
	if event is InputEventMouseMotion and is_clicked:
		var pos = get_local_mouse_position()
		if last_pos == pos:
			pass
		clicked_container.rect_position += pos - last_pos
		#last_pos = Vector2(min(max(0, pos.x), columns-1), min(max(0, pos.y), rows-1))
		last_pos = pos

func _on_selection_change():
	_reset_active_slots()
	_set_active_slots(start_pos, last_pos)
	
func _reset_active_slots():
	for slot in get_children():
		slot._set_focus(false)
	
func _get_slot(x: float, y: float) -> Slot:
	var index: int = y * columns + x
	return get_children()[index]

func _set_active_slots(start: Vector2, end: Vector2):
	var x_step: int = 1 if end.x >= start.x else -1
	var y_step: int = 1 if end.y >= start.y else -1
	#end = Vector2(end.x + x_step, end.y + y_step) #obsolete since we use Rect2
	for i in range(start.x, end.x, x_step):
		for j in range(start.y, end.y, y_step):
			var slot: Panel = _get_slot(i, j)
			slot._set_focus(true)

func _get_mouse_slot_position():
	var mouse_pos = self.get_local_mouse_position()
	return Vector2(mouse_pos.x / Shared.SLOT_SIZE, mouse_pos.y / Shared.SLOT_SIZE).floor()

func _get_slot_vector(pos: Vector2):
	return Vector2(pos.x / Shared.SLOT_SIZE, pos.y / Shared.SLOT_SIZE).floor()

func _on_click():
	var pos = _get_mouse_slot_position()
	var inventory_item = _get_inventory_item_by_position(pos)
	if inventory_item == null:
		return
	var area = Rect2(inventory_item.pos, inventory_item.dimension)
	_reset_active_slots()
	_set_active_slots(area.position, area.end)
	
	clicked_inventory_item = inventory_item
	clicked_container = _get_slot(inventory_item.pos.x, inventory_item.pos.y).container
	
	start_pos = get_local_mouse_position()
	last_pos = start_pos
	is_clicked = true

func _on_release():
	if(!is_clicked):
		return
	is_clicked = false
	var distance = _get_slot_vector(last_pos) - _get_slot_vector(start_pos)
	clicked_container.rect_position = Vector2(0, 0)
	
	var raw_end_pos = clicked_inventory_item.pos + distance
	var dim = clicked_inventory_item.dimension
	var end_pos = Vector2(min(max(0, raw_end_pos.x), columns-dim.x), min(max(0, raw_end_pos.y), rows-dim.y))
	
	var area = Rect2(end_pos, dim)
	if(_position_can_move(clicked_inventory_item, area)):
		clicked_inventory_item.pos = end_pos

	Shared.emit_signal("refresh_gui")
	_reset_active_slots()
	_set_active_slots(clicked_inventory_item.pos, clicked_inventory_item.pos+dim)
	pass

func _get_inventory_item_by_position(pos: Vector2):
	for inventory_item in Shared.inventory_items:
		var area = Rect2(inventory_item.pos, inventory_item.dimension)
		if(area.has_point(pos)):
			return inventory_item
	return null


func _position_can_move(item: InventoryItem, area: Rect2):
	for inventory_item in Shared.inventory_items:
		if(inventory_item == item):
			continue
		var item_area = Rect2(inventory_item.pos, inventory_item.dimension)
		if(area.intersects(item_area)):
			return false
	return true
