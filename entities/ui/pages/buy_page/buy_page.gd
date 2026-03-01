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
	# To update the sold out tag
	$ScrollList.set_items(GameState.get_all_weapons_buy_list_item_instances())


func _try_buy_weapon(id: StringName) -> void:
	# TODO: Play a sound or toast or something
	if GameState.try_to_buy_a_weapon_by_id(id):
		pass
	else:
		pass
