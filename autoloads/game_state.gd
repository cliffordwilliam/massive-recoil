# GameState
extends Node

# Events
signal weapon_equipped(equipped_arm: Resource)
signal weapon_bought

# DB tables
# Player
var money: int = 9
var equipped_weapon_id: StringName = "handgun"
# Weapons
var weapons: Dictionary[StringName, Dictionary] = {
	"handgun": {
		"arms_sprite": preload("uid://c6ackeixi1emi"),
		"icon_sprite": preload("uid://8ibmk0y17sbf"),
		"buy_page_list_item_scene": preload("uid://c80k1dw0o4xun"),
		"inv_page_list_item_scene": preload("uid://cln5lsvnj1a8x"),
		"is_owned": true,
		"was_bought": true,
		"price": 5,
		"magazine_size": 10,
		"magazine_current": 10,
		"reserve_ammo": 20,
	},
	"rifle": {
		"arms_sprite": preload("uid://bd23x5s463v8v"),
		"icon_sprite": preload("uid://dj2ky63h5gknm"),
		"buy_page_list_item_scene": preload("uid://dwrd7ddvl26x3"),
		"inv_page_list_item_scene": preload("uid://dnb2k8vk62fni"),
		"is_owned": false,
		"was_bought": false,
		"price": 10,
		"magazine_size": 30,
		"magazine_current": 30,
		"reserve_ammo": 30,
	},
}


# Service/repo layer
func consume_equipped_ammo() -> bool:
	if weapons[equipped_weapon_id].magazine_current > 0:
		weapons[equipped_weapon_id].magazine_current -= 1
		return true
	return false


func get_weapon_icon_by_id(id: StringName) -> Resource:
	return weapons[id].icon_sprite


func get_all_money() -> int:
	return money


func add_money() -> void:
	GameState.money += 1


func pick_up_weapon(id: StringName) -> void:
	GameState.weapons[id].is_owned = true


func buy_weapon(id: StringName) -> void:
	if money >= weapons[id].price and not weapons[id].is_owned:
		money -= weapons[id].price
		weapons[id].was_bought = true
		weapons[id].is_owned = true
		weapon_bought.emit()


func get_equipped_arm() -> Resource:
	return weapons[equipped_weapon_id].arms_sprite


func get_all_weapons() -> Array:
	return weapons.keys().map(
		func(id: StringName) -> Dictionary: return { "i": id, "w": weapons[id] }
	)


func get_all_weapons_buy_list_item_instances() -> Array:
	return get_all_weapons().map(
		func(d: Dictionary) -> BuyPageListItem:
			return d.w.buy_page_list_item_scene \
			.instantiate().zet_name(d.i).show_tags(not d.w.was_bought, d.w.is_owned)
	)


func get_owned_weapons_inv_list_item_instances() -> Array:
	return get_owned_weapons().map(
		func(d: Dictionary) -> InventoryPageListItem:
			return d.w.inv_page_list_item_scene.instantiate().zet_name(d.i). \
			show_equipped_tag(equipped_weapon_id == d.i)
	)


func get_owned_weapons() -> Array:
	return get_all_weapons().filter(
		func(d: Dictionary) -> bool: return d.w.is_owned
	)


func equip_weapon(weapon_id: StringName) -> void:
	equipped_weapon_id = weapon_id
	weapon_equipped.emit(get_equipped_arm())
