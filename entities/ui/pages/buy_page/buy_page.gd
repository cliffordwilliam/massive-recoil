class_name BuyPage
extends Sprite2D


func _ready() -> void:
	$ScrollList.index_changed.connect(
		func(id: StringName) -> void: $Icon.texture = GameState.get_weapon_by_id(id).icon_sprite
	)
	$ScrollList.item_selected.connect(func(id: StringName) -> void: GameState.buy_weapon(id))
	GameState.weapon_bought.connect(func() -> void: _fetch_data())
	_fetch_data()


func _fetch_data() -> void:
	$Money.display_number(GameState.get_all_money())
	$ScrollList.set_items(GameState.get_all_weapons_buy_list_item_instances())
