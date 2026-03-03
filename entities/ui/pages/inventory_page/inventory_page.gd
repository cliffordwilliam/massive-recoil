# This page is where player see owned weapons, ammo, money. They can pick and equip one weapon
class_name InventoryPage
extends BasePage

@onready var scroll_list: ScrollList = $ScrollList
@onready var money: NumberDisplay = $Money
@onready var handgun_ammo: NumberDisplay = $HandgunAmmo
@onready var rifle_ammo: NumberDisplay = $RifleAmmo


func _hydrate_ui() -> void:
	handgun_ammo.display_number(GameState.get_weapon_reserve_ammo_by_id(&"handgun"))
	rifle_ammo.display_number(GameState.get_weapon_reserve_ammo_by_id(&"rifle"))
	money.display_number(GameState.get_money_count())
	scroll_list.set_items(_get_owned_weapons_list_item())


func _get_owned_weapons_list_item() -> Array:
	return GameState.get_owned_weapons().map(_create_list_item)


func _create_list_item(d: Dictionary) -> InventoryPageListItem:
	var item: InventoryPageListItem = d.w.inv_page_list_item_scene.instantiate()
	item.set_id(d.i)
	item.show_equipped_tag(GameState.get_equipped_weapon_id() == d.i)
	item.set_magazine_current_value(d.w.magazine_current)
	return item


func _on_scroll_list_item_selected(id: StringName) -> void: # Connected via engine GUI
	GameState.equip_a_new_weapon_by_id(id)
	_hydrate_ui()
