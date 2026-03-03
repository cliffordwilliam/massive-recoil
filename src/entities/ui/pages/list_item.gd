# This is the base class for items managed by ScrollList, so parent must be ScrollList
# Each needs unique name and share same sprite height
class_name ListItem
extends Sprite2D


func set_id(id: StringName) -> void:
	name = id


func get_height() -> int:
	return int(get_rect().size.y)
