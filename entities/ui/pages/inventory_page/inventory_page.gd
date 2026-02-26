class_name InventoryPage
extends Sprite2D


func _ready() -> void:
	$ScrollList.item_selected.connect(func(id: StringName) -> void: GameState.equip_weapon(id))
	$ScrollList.set_items(GameState.get_weapons_inv_page_list_item_instances())
