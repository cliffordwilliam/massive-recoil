class_name Slot extends Panel
var texture = preload("res://inventory/grid.png")
var item
var container

func _ready():
	self.focus_mode = Control.FOCUS_CLICK
	self.rect_size = Vector2(Shared.SLOT_SIZE, Shared.SLOT_SIZE)
	_render(_get_stylebox(false))
	pass
	
func _init():
	container = CenterContainer.new()
	add_child(container)

func _render(style: StyleBoxTexture):
	set("custom_styles/panel", style)

func _get_stylebox(hovered: bool):
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = texture
	style.region_rect = Rect2(0, 0, 58, 58)
	style.modulate_color.a = 1.0 if hovered else 0.5
	return style

func _set_focus(focus: bool):
	_render(_get_stylebox(focus))
	pass
