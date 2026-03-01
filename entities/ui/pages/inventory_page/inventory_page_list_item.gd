class_name InventoryPageListItem
extends ListItem

var mag_current: int = 0


func _ready() -> void:
	$MagazineCurrent.display_number(mag_current)


func show_equipped_tag(value: bool) -> InventoryPageListItem:
	$EquippedTag.visible = value
	return self


# This is called before my ready
func set_mag_current(value: int) -> InventoryPageListItem:
	mag_current = value
	return self
