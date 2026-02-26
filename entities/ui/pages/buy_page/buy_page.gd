class_name BuyPage
extends Sprite2D

@onready var scroll_list: ScrollList = $ScrollList
@onready var thumbnail: Sprite2D = $Thumbnail
@onready var money: NumberDisplay = $Money


func _ready() -> void:
	scroll_list.index_changed.connect(
		func(id: StringName) -> void: thumbnail.texture = GameState.weapons[id].thumbnail_sprite
	)
	scroll_list.item_selected.connect(func(id: StringName) -> void: GameState.buy_weapon(id))
	GameState.weapon_bought.connect(func() -> void: _fetch_data())
	_fetch_data()


func _fetch_data() -> void:
	money.display_number(GameState.money)
	scroll_list.set_items(GameState.get_weapons_buy_page_list_item_instances())
