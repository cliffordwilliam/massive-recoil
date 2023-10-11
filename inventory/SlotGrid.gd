extends GridContainer
var start_pos: Vector2
var last_pos: Vector2
var is_clicked: bool
onready var slot_size: int = get_child(0).rect_size.x
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
		var pos = _get_mouse_slot_position()
		if last_pos == pos:
			pass
		last_pos = Vector2(min(max(0, pos.x), columns-1), min(max(0, pos.y), rows-1))
		emit_signal("selection_changed")

func _on_selection_change():
	_reset_active_slots()
	_set_active_slots(start_pos, last_pos)
	
func _reset_active_slots():
	for slot in get_children():
		slot._set_focus(false)
	
func _get_slot(x: float, y: float):
	var index: int = y * columns + x
	return get_children()[index]

func _set_active_slots(start: Vector2, end: Vector2):
	var x_step: int = 1 if end.x >= start.x else -1
	var y_step: int = 1 if end.y >= start.y else -1
	end = Vector2(last_pos.x + x_step, last_pos.y + y_step)
	for i in range(start.x, end.x, x_step):
		for j in range(start.y, end.y, y_step):
			var slot: Panel = _get_slot(i, j)
			slot._set_focus(true)

func _get_mouse_slot_position():
	var mouse_pos = self.get_local_mouse_position()
	return Vector2(mouse_pos.x / slot_size, mouse_pos.y / slot_size).floor()

func _on_click():
	start_pos = _get_mouse_slot_position()
	last_pos = start_pos
	is_clicked = true
	emit_signal("selection_changed")
	pass

func _on_release():
	is_clicked = false
	pass
