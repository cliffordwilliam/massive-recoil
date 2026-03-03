# This is the base class for pages managed by PageRouter, so parent must be PageRouter
class_name BasePage
extends Sprite2D

# All pages can be toggled on/off (off means never process and invisible)
var is_active: bool:
	set(value):
		is_active = value
		process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED
		visible = is_active
		if is_active:
			_hydrate_ui() # Fetch data everytime I wake up


func _hydrate_ui() -> void:
	pass # Children override fetch logic here
