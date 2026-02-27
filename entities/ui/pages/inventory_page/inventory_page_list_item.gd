class_name InventoryPageListItem
extends ListItem


func show_equipped_tag(value: bool) -> InventoryPageListItem:
	$EquippedTag.visible = value
	return self
