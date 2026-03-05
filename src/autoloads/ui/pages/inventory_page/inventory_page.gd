# Page where the player sees owned weapons, ammo, and money. They can pick and equip one weapon.
class_name InventoryPage
extends BasePage

@onready var scroll_list: ScrollList = $ScrollList
@onready var money: NumberDisplay = $Money
@onready var handgun_ammo: NumberDisplay = $HandgunAmmo
@onready var rifle_ammo: NumberDisplay = $RifleAmmo


func _hydrate_ui() -> void:
	# There are only less than 6 ammo types in the game, so hardcode is fine.
	handgun_ammo.display_number(GameState.get_weapon_reserve_ammo_by_id(&"handgun"))
	rifle_ammo.display_number(GameState.get_weapon_reserve_ammo_by_id(&"rifle"))
	money.display_number(GameState.get_money_count())
	# Pages regenerate all list items every open.
	# This is Acceptable since game has small item counts (less than 20).
	scroll_list.set_items(_get_owned_weapons_list_item())


func _get_owned_weapons_list_item() -> Array[ListItem]:
	# Array.map() always returns an untyped Array regardless of the callable's return type,
	# so it cannot be passed to ScrollList.set_items(Array[ListItem]) without a type error.
	# Docs: docs/godot/classes/class_array.rst — "Array map(method: Callable) const"
	# Build a typed Array[ListItem] manually instead.
	var result: Array[ListItem] = []
	for weapon: WeaponData in GameState.get_owned_weapons():
		result.append(_create_list_item(weapon))
	return result


func _create_list_item(weapon_data: WeaponData) -> InventoryPageListItem:
	var item: InventoryPageListItem = weapon_data.inv_page_list_item_scene.instantiate()
	item.set_id(weapon_data.id)
	item.show_equipped_tag(GameState.get_equipped_weapon_id() == weapon_data.id)
	item.set_magazine_current_value(weapon_data.magazine_current)
	return item


func _on_scroll_list_item_selected(id: StringName) -> void: # Connected via engine GUI.
	GameState.equip_a_new_weapon_by_id(id)
	_hydrate_ui()
