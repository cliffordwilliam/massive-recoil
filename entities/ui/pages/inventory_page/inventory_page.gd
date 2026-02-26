class_name InventoryPage
extends Sprite2D

@onready var scroll_list: ScrollList = $ScrollList


func _ready() -> void:
	scroll_list.item_selected.connect(func(id: StringName) -> void: GameState.equip_weapon(id))
	scroll_list.set_items(GameState.get_weapons_inv_page_list_item_instances())
