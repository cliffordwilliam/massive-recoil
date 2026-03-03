# Shared script for all inventory item sprite scene, each has magazine counter and equipped tag
class_name InventoryPageListItem
extends ListItem

const MAX_MAGAZINE_CURRENT_VALUE: int = 999 # Cannot render magazine counter more than this

var magazine_current_value: int = 0
var is_equipped_tag_visible: bool = false

@onready var equipped_tag: Sprite2D = $EquippedTag
@onready var magazine_current: NumberDisplay = $MagazineCurrent


func _ready() -> void:
	magazine_current.display_number(magazine_current_value)
	equipped_tag.visible = is_equipped_tag_visible


func show_equipped_tag(value: bool) -> void:
	# This can be called before or after my ready is called
	is_equipped_tag_visible = value
	if is_node_ready():
		equipped_tag.visible = is_equipped_tag_visible


func set_magazine_current_value(value: int) -> void:
	# This can be called before or after my ready is called
	magazine_current_value = mini(value, MAX_MAGAZINE_CURRENT_VALUE)
	if is_node_ready():
		magazine_current.display_number(magazine_current_value)
