# GameState
extends Node

signal new_weapon_equipped
signal weapon_bought

# Player
var money: int = 9
var equipped_weapon_id: StringName = "handgun"
# Weapons
var weapons: Dictionary[StringName, Dictionary] = {
	"handgun": {
		"arms_sprite": preload("uid://c6ackeixi1emi"),
		"icon_sprite": preload("uid://8ibmk0y17sbf"),
		"description_sprite": preload("uid://bxw0vrryxyyd"),
		"buy_page_list_item_scene": preload("uid://c80k1dw0o4xun"),
		"inv_page_list_item_scene": preload("uid://cln5lsvnj1a8x"),
		"is_owned": true,
		"was_bought": true,
		"price": 5,
		"magazine_size": 10,
		"magazine_current": 10,
		"reserve_ammo": 20,
		"reload_speed": 1.73,
	},
	"rifle": {
		"arms_sprite": preload("uid://bd23x5s463v8v"),
		"icon_sprite": preload("uid://dj2ky63h5gknm"),
		"description_sprite": preload("uid://pmadodqocwuj"),
		"buy_page_list_item_scene": preload("uid://dwrd7ddvl26x3"),
		"inv_page_list_item_scene": preload("uid://dnb2k8vk62fni"),
		"is_owned": false,
		"was_bought": false,
		"price": 10,
		"magazine_size": 30,
		"magazine_current": 30,
		"reserve_ammo": 30,
		"reload_speed": 2.37,
	},
}


func get_equipped_weapon_id() -> StringName:
	return equipped_weapon_id


func is_weapon_exists_by_id(id: StringName) -> bool:
	return id in weapons


func get_weapon_reserve_ammo_by_id(id: StringName) -> int:
	if not is_weapon_exists_by_id(id):
		return 0
	return weapons[id].reserve_ammo


func equipped_weapon_can_reload() -> bool:
	var weapon: Dictionary = weapons[equipped_weapon_id]
	return weapon.reserve_ammo > 0 and weapon.magazine_current < weapon.magazine_size


func reload_weapon_by_id(id: StringName) -> void:
	var weapon: Dictionary = weapons[id]
	var needed: int = weapon.magazine_size - weapon.magazine_current
	var available: int = min(needed, weapon.reserve_ammo)
	weapon.magazine_current += available
	weapon.reserve_ammo -= available


func try_eat_one_equipped_weapon_ammo() -> bool:
	if weapons[equipped_weapon_id].magazine_current > 0:
		weapons[equipped_weapon_id].magazine_current -= 1
		return true
	return false


func get_equipped_weapon_reload_speed() -> float:
	return weapons[equipped_weapon_id].reload_speed


func get_weapon_description_by_id(id: StringName) -> Resource:
	if not is_weapon_exists_by_id(id):
		return null
	return weapons[id].description_sprite


func get_weapon_icon_by_id(id: StringName) -> Resource:
	if not is_weapon_exists_by_id(id):
		return null
	return weapons[id].icon_sprite


func get_all_money() -> int:
	return money


func add_one_to_money() -> void:
	money += 1


func pick_up_a_weapon_by_id(id: StringName) -> void:
	if not is_weapon_exists_by_id(id):
		return
	weapons[id].is_owned = true


func try_to_buy_a_weapon_by_id(id: StringName) -> bool:
	if not is_weapon_exists_by_id(id):
		return false
	if money >= weapons[id].price and not weapons[id].is_owned:
		money -= weapons[id].price
		weapons[id].was_bought = true
		weapons[id].is_owned = true
		weapon_bought.emit()
		return true
	return false


func get_new_equipped_weapon_arms_sprite() -> Resource:
	return weapons[equipped_weapon_id].arms_sprite


func get_all_weapons() -> Array:
	return weapons.keys().map(
		func(id: StringName) -> Dictionary: return { "i": id, "w": weapons[id] }
	)


func get_owned_weapons() -> Array:
	return get_all_weapons().filter(
		func(d: Dictionary) -> bool: return d.w.is_owned
	)


func equip_a_new_weapon_by_id(id: StringName) -> void:
	if not is_weapon_exists_by_id(id):
		return
	equipped_weapon_id = id
	new_weapon_equipped.emit()
