class_name InventoryPage
extends Sprite2D


func _ready() -> void:
	$HandgunAmmo.display_number(GameState.get_all_handgun_ammo())
	$RifleAmmo.display_number(GameState.get_all_rifle_ammo())
	$Money.display_number(GameState.get_all_money())
	$ScrollList.item_selected. \
	connect(func(id: StringName) -> void: GameState.equip_a_new_weapon_by_id(id))
	GameState.new_weapon_equipped.connect(func() -> void: _hydrate_fe())
	_hydrate_fe()


func _hydrate_fe() -> void:
	# To update the equipped tag
	$ScrollList.set_items(GameState.get_owned_weapons_inv_list_item_instances())
