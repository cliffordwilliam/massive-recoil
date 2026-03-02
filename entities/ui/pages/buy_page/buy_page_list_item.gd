# Shared script for all buy item sprite scene, it has new and sold out tags
class_name BuyPageListItem
extends ListItem

var is_new_tag_visible: bool = false
var is_out_tag_visible: bool = false

@onready var new_tag: Sprite2D = $NewTag
@onready var out_tag: Sprite2D = $OutTag


func _ready() -> void:
	new_tag.visible = is_new_tag_visible
	out_tag.visible = is_out_tag_visible


func show_tags(show_new_tag: bool, is_sold_out: bool) -> void:
	is_new_tag_visible = show_new_tag
	is_out_tag_visible = is_sold_out
	if is_node_ready(): # To support calling this before or after ready
		new_tag.visible = is_new_tag_visible
		out_tag.visible = is_out_tag_visible
