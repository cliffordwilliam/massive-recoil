class_name InventoryPage
extends Sprite2D


func _ready() -> void:
	$HandgunAmmo.display_number(GameState.get_weapon_reserve_ammo_by_id("handgun"))
	$RifleAmmo.display_number(GameState.get_weapon_reserve_ammo_by_id("rifle"))
	$Money.display_number(GameState.get_all_money())
	$ScrollList.item_selected. \
	connect(func(id: StringName) -> void: GameState.equip_a_new_weapon_by_id(id))
	GameState.new_weapon_equipped.connect(func() -> void: _hydrate_fe())
	_hydrate_fe()


func _hydrate_fe() -> void:
	$ScrollList.set_items(_get_owned_weapons_inv_list_item_instances()) # To update the equipped tag


func _get_owned_weapons_inv_list_item_instances() -> Array:
	return GameState.get_owned_weapons().map(
		func(d: Dictionary) -> InventoryPageListItem:
			return d.w.inv_page_list_item_scene.instantiate().set_id(d.i). \
			show_equipped_tag(GameState.get_equipped_weapon_id() == d.i). \
			set_mag_current(d.w.magazine_current)
	)
