# Shows all weapons and money. Player can browse and buy one weapon.
# Player cannot buy a weapon they already own.
class_name BuyPage
extends BasePage

@onready var money: NumberDisplay = $Money
@onready var icon: Sprite2D = $Icon
@onready var scroll_list: ScrollList = $ScrollList
@onready var description: Sprite2D = $Description


func _hydrate_ui() -> void:
	money.display_number(GameState.get_money_count())
	# Pages regenerate all list items every open.
	# This is Acceptable since game has small item counts (less than 20)
	scroll_list.set_items(_get_all_weapons_buy_list_item())


func _get_all_weapons_buy_list_item() -> Array[ListItem]:
	# Array.map() always returns an untyped Array regardless of the callable's return type,
	# so it cannot be passed to ScrollList.set_items(Array[ListItem]) without a type error.
	# Docs: docs/godot/classes/class_array.rst — "Array map(method: Callable) const"
	# Build a typed Array[ListItem] manually instead.
	var result: Array[ListItem] = []
	for weapon: WeaponData in GameState.get_all_weapons():
		result.append(_create_list_item(weapon))
	return result


func _create_list_item(weapon_data: WeaponData) -> BuyPageListItem:
	var item: BuyPageListItem = weapon_data.buy_page_list_item_scene.instantiate()
	item.set_id(weapon_data.id)
	item.show_tags(not weapon_data.was_bought, weapon_data.is_owned) # is_owned means sold out
	return item


func _on_scroll_list_render_updated(id: StringName) -> void: # Connected via engine GUI
	if GameState.weapon_exists(id):
		icon.texture = GameState.get_weapon_icon_by_id(id)
		description.texture = GameState.get_weapon_description_by_id(id)
	else:
		push_warning("BuyPage: weapon does not exist")


func _on_scroll_list_item_selected(id: StringName) -> void: # Connected via engine GUI
	if GameState.try_to_buy_a_weapon_by_id(id):
		_hydrate_ui()
	# TODO: Play a sound on success and fail later
