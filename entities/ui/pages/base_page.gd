class_name BasePage
extends Sprite2D


func set_enabled(enabled: bool) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	visible = enabled
	if enabled:
		_hydrate_ui() # Get data on first load


func _hydrate_ui() -> void:
	pass
