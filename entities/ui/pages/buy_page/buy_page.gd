class_name BuyPage
extends Sprite2D


func _ready() -> void:
	$ScrollList.index_changed.connect(
		func(id: StringName) -> void:
			$Icon.texture = GameState.get_weapon_icon_by_id(id)
			$Description.texture = GameState.get_weapon_description_by_id(id)
	)
	$ScrollList.item_selected.connect(func(id: StringName) -> void: _try_buy_weapon(id))
	GameState.weapon_bought.connect(func() -> void: _hydrate_ui())
	_hydrate_ui()


func _hydrate_ui() -> void:
	$Money.display_number(GameState.get_money_count())
	$ScrollList.set_items(_get_all_weapons_buy_list_item_instances()) # To update the sold out tag


func _get_all_weapons_buy_list_item_instances() -> Array:
	return GameState.get_all_weapons().map(_create_weapon_buy_list_item)


func _create_weapon_buy_list_item(d: Dictionary) -> BuyPageListItem:
	var item: BuyPageListItem = d.w.buy_page_list_item_scene.instantiate()
	item.set_id(d.i)
	item.show_tags(not d.w.was_bought, d.w.is_owned)
	return item


func _try_buy_weapon(id: StringName) -> void:
	GameState.try_to_buy_a_weapon_by_id(id) # TODO: Play a sound on success and fail later okay
