class_name BuyPageListItem
extends ListItem


func set_tag(new: bool, out: bool) -> BuyPageListItem:
	$NewTag.visible = new
	$OutTag.visible = out
	return self
