class_name InventoryPageListItem
extends ListItem

var mag_current: int = 0
var is_equipped_tag_visible: bool = false

@onready var equipped_tag: Sprite2D = $EquippedTag
@onready var magazine_current: NumberDisplay = $MagazineCurrent


func _ready() -> void:
	magazine_current.display_number(mag_current)
	equipped_tag.visible = is_equipped_tag_visible


func show_equipped_tag(value: bool) -> InventoryPageListItem:
	is_equipped_tag_visible = value
	return self


func set_mag_current(value: int) -> InventoryPageListItem:
	mag_current = value
	return self
