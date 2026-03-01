class_name BuyPage
extends Sprite2D


func _ready() -> void:
	$ScrollList.index_changed.connect(
		func(id: StringName) -> void:
			$Icon.texture = GameState.get_weapon_icon_by_id(id)
			$Description.texture = GameState.get_weapon_description_by_id(id)
	)
	$ScrollList.item_selected.connect(func(id: StringName) -> void: _try_buy_weapon(id))
	GameState.weapon_bought.connect(func() -> void: _hydrate_fe())
	_hydrate_fe()


func _hydrate_fe() -> void:
	$Money.display_number(GameState.get_all_money())
	$ScrollList.set_items(_get_all_weapons_buy_list_item_instances()) # To update the sold out tag


func _get_all_weapons_buy_list_item_instances() -> Array:
	return GameState.get_all_weapons().map(
		func(d: Dictionary) -> BuyPageListItem:
			return (d.w.buy_page_list_item_scene.instantiate().set_id(d.i).show_tags(not d.w.was_bought, d.w.is_owned) )
	)


func _try_buy_weapon(id: StringName) -> void:
	# TODO: Play a sound on success and fail later okay
	GameState.try_to_buy_a_weapon_by_id(id)
