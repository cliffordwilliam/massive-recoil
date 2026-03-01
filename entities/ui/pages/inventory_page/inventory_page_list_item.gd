class_name InventoryPageListItem
extends ListItem

var mag_current: int = 0
var is_equipped_tag_visible: bool = false


func _ready() -> void:
	$MagazineCurrent.display_number(mag_current)
	$EquippedTag.visible = is_equipped_tag_visible


func show_equipped_tag(value: bool) -> InventoryPageListItem:
	is_equipped_tag_visible = value
	return self


func set_mag_current(value: int) -> InventoryPageListItem:
	mag_current = value
	return self
