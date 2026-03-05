# Shared script for all buy‑page item sprite scenes; each has a "new" tag and a "sold out" tag.
class_name BuyPageListItem
extends ListItem

var is_new_tag_visible: bool = false
var is_out_tag_visible: bool = false

@onready var new_tag: Sprite2D = $NewTag
@onready var out_tag: Sprite2D = $OutTag # out_tag means sold out.


func _ready() -> void:
	_assign_children_properties()


func show_tags(show_new_tag: bool, is_sold_out: bool) -> void:
	# This can be called before or after my _ready() is called.
	is_new_tag_visible = show_new_tag
	is_out_tag_visible = is_sold_out
	if is_node_ready():
		_assign_children_properties()


func _assign_children_properties() -> void:
	new_tag.visible = is_new_tag_visible
	out_tag.visible = is_out_tag_visible
