class_name BuyPage
extends BasePage

@onready var money: NumberDisplay = $Money
@onready var icon: Sprite2D = $Icon
@onready var scroll_list: ScrollList = $ScrollList
@onready var description: Sprite2D = $Description


func _hydrate_ui() -> void:
	if not visible:
		return
	money.display_number(GameState.get_money_count())
	# During page active, only possible to update the sold out tag
	scroll_list.set_items(_get_all_weapons_buy_list_item_instances())


func _get_all_weapons_buy_list_item_instances() -> Array:
	return GameState.get_all_weapons().map(_create_weapon_buy_list_item)


func _create_weapon_buy_list_item(d: Dictionary) -> BuyPageListItem:
	var item: BuyPageListItem = d.w.buy_page_list_item_scene.instantiate()
	item.set_id(d.i)
	item.show_tags(not d.w.was_bought, d.w.is_owned) # is_owned means sold out
	return item


func _try_buy_weapon(id: StringName) -> void:
	GameState.try_to_buy_a_weapon_by_id(id) # TODO: Play a sound on success and fail later okay


func _on_scroll_list_index_changed(id: StringName) -> void: # Connected via engine GUI
	if not GameState.weapon_exists(id):
		return
	icon.texture = GameState.get_weapon_icon_by_id(id)
	description.texture = GameState.get_weapon_description_by_id(id)


func _on_scroll_list_item_selected(id: StringName) -> void: # Connected via engine GUI
	_try_buy_weapon(id)
	_hydrate_ui()
