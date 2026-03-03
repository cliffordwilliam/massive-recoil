@abstract
# Base class for all pages managed by PageRouter. Parent must be PageRouter.
class_name BasePage
extends Sprite2D

# All pages can be toggled on/off (off means never processes and stays invisible).
var is_active: bool:
	set(value):
		is_active = value
		process_mode = Node.PROCESS_MODE_INHERIT if is_active else Node.PROCESS_MODE_DISABLED
		visible = is_active
		if is_active:
			_hydrate_ui() # Fetch data every time I wake up.


func _hydrate_ui() -> void:
	pass # Children must override fetch logic here.
