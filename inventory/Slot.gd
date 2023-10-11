extends Panel
var texture = preload("res://inventory/grid.png")

func _ready():
	self.focus_mode = Control.FOCUS_CLICK
	_render(_get_stylebox(false))
	pass

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
