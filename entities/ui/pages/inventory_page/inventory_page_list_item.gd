class_name InventoryPageListItem
extends ListItem

var magazine_current_value: int = 0
var is_equipped_tag_visible: bool = false

@onready var equipped_tag: Sprite2D = $EquippedTag
@onready var magazine_current: NumberDisplay = $MagazineCurrent


func _ready() -> void:
	magazine_current.display_number(magazine_current_value)
	equipped_tag.visible = is_equipped_tag_visible


func show_equipped_tag(value: bool) -> void:
	is_equipped_tag_visible = value
	if is_node_ready():
		equipped_tag.visible = is_equipped_tag_visible


func set_mag_current(value: int) -> void:
	magazine_current_value = value
	if is_node_ready():
		magazine_current.display_number(magazine_current_value)
