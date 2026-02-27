class_name BuyPageListItem
extends ListItem


func show_tags(show_new_tag: bool, show_out_tag: bool) -> BuyPageListItem:
	$NewTag.visible = show_new_tag
	$OutTag.visible = show_out_tag
	return self
