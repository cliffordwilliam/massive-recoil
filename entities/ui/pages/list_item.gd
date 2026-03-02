# This is the base class for items managed by ScrollList, so parent must be ScrollList
class_name ListItem
extends Sprite2D


func set_id(id: StringName) -> void:
	name = id


func get_height() -> int:
	return int(get_rect().size.y)
