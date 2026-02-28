class_name BuyPage
extends Sprite2D


func _ready() -> void:
	$ScrollList.index_changed. \
	connect(func(id: StringName) -> void: $Icon.texture = GameState.get_weapon_icon_by_id(id))
	$ScrollList.item_selected.connect(func(id: StringName) -> void: GameState.buy_weapon(id))
	GameState.weapon_bought.connect(func() -> void: _hydrate_fe())
	_hydrate_fe()


func _hydrate_fe() -> void:
	$Money.display_number(GameState.get_all_money())
	$ScrollList.set_items(GameState.get_all_weapons_buy_list_item_instances())
