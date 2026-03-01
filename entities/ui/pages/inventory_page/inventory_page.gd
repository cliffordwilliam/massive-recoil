class_name InventoryPage
extends Sprite2D


func _ready() -> void:
	$HandgunAmmo.display_number(GameState.get_all_handgun_ammo())
	$RifleAmmo.display_number(GameState.get_all_rifle_ammo())
	$Money.display_number(GameState.get_all_money())
	$ScrollList.item_selected.connect(func(id: StringName) -> void: GameState.equip_new_weapon(id))
	GameState.new_weapon_equipped.connect(func() -> void: _hydrate_fe())
	_hydrate_fe()


func _hydrate_fe() -> void:
	$ScrollList.set_items(GameState.get_owned_weapons_inv_list_item_instances())
