class_name InventoryPage
extends Sprite2D


func _ready() -> void:
	$Money.display_number(GameState.get_all_money())
	$ScrollList.item_selected.connect(func(id: StringName) -> void: GameState.equip_weapon(id))
	GameState.weapon_equipped.connect(func(_arm: Resource) -> void: _read_db())
	_read_db()


func _read_db() -> void:
	$ScrollList.set_items(GameState.get_owned_weapons_inv_list_item_instances())
