class_name InventoryPage
extends Sprite2D

@onready var scroll_list: ScrollList = $ScrollList
@onready var money: NumberDisplay = $Money
@onready var handgun_ammo: NumberDisplay = $HandgunAmmo
@onready var rifle_ammo: NumberDisplay = $RifleAmmo


func _ready() -> void:
	handgun_ammo.display_number(GameState.get_weapon_reserve_ammo_by_id("handgun"))
	rifle_ammo.display_number(GameState.get_weapon_reserve_ammo_by_id("rifle"))
	money.display_number(GameState.get_money_count())
	GameState.new_weapon_equipped.connect(_hydrate_ui)
	_hydrate_ui()


func _hydrate_ui() -> void:
	scroll_list.set_items(_get_owned_weapons_inv_list_item_instances()) # To update the equipped tag


func _get_owned_weapons_inv_list_item_instances() -> Array:
	return GameState.get_owned_weapons().map(_create_weapon_list_item)


func _create_weapon_list_item(d: Dictionary) -> InventoryPageListItem:
	var item: InventoryPageListItem = d.w.inv_page_list_item_scene.instantiate()
	item.set_id(d.i)
	item.show_equipped_tag(GameState.get_equipped_weapon_id() == d.i)
	item.set_mag_current(d.w.magazine_current)
	return item


func _on_scroll_list_item_selected(id: StringName) -> void: # Connected via engine GUI
	GameState.equip_a_new_weapon_by_id(id)
