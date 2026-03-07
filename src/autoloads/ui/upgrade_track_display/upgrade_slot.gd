# The only node that renders upgrade slots using sprites.
class_name UpgradeSlot
extends Sprite2D


func show_dim() -> void:
	modulate = Color("#00528a")


func show_bright() -> void:
	modulate = Color("#47f9fc")


func get_width() -> int:
	return texture.get_width()
