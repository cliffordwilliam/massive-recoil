class_name BuyPageListItem
extends ListItem

var is_new_tag_visible: bool = false
var is_out_tag_visible: bool = false


func _ready() -> void:
	$NewTag.visible = is_new_tag_visible
	$OutTag.visible = is_out_tag_visible


func show_tags(show_new_tag: bool, show_out_tag: bool) -> BuyPageListItem:
	is_new_tag_visible = show_new_tag
	is_out_tag_visible = show_out_tag
	return self
