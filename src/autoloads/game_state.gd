# GameState
# Single source of truth for all runtime game state.
#
# Weapons: preload() returns the engine-cached resource instance, so HANDGUN and RIFLE
# are the same objects for the entire session. This is intentional — there are no
# duplicate weapons and this is single-player, so the cached instance IS the live state.
# Do not call .duplicate() on them; that would break the shared-instance contract.
extends Node

signal new_weapon_equipped

const HANDGUN: WeaponData = preload("uid://bh7bnh8qqxn1b")
const RIFLE: WeaponData = preload("uid://bu1h08icwgww")

# Player
var money: int = 5
var equipped_weapon_id: StringName = &""
# Weapons
var weapons: Dictionary[StringName, WeaponData] = {
	&"handgun": HANDGUN,
	&"rifle": RIFLE,
}


func get_equipped_weapon_id() -> StringName:
	return equipped_weapon_id


func weapon_exists(id: StringName) -> bool:
	return id in weapons


func get_weapon_reserve_ammo_by_id(id: StringName) -> int:
	if not weapon_exists(id):
		return 0
	return weapons[id].reserve_ammo


func equipped_weapon_can_reload() -> bool:
	if not weapon_exists(equipped_weapon_id):
		return false
	var weapon: WeaponData = weapons[equipped_weapon_id]
	return weapon.reserve_ammo > 0 and weapon.magazine_current < weapon.magazine_size


func reload_weapon_by_id(id: StringName) -> void:
	if not weapon_exists(id):
		return
	var weapon: WeaponData = weapons[id]
	var needed: int = weapon.magazine_size - weapon.magazine_current
	var available: int = mini(needed, weapon.reserve_ammo)
	weapon.magazine_current += available
	weapon.reserve_ammo -= available


func try_consume_ammo() -> bool:
	if not weapon_exists(equipped_weapon_id):
		return false
	if weapons[equipped_weapon_id].magazine_current > 0:
		weapons[equipped_weapon_id].magazine_current -= 1
		return true
	return false


func get_equipped_weapon_reload_speed() -> float:
	if not weapon_exists(equipped_weapon_id):
		return 0.0
	return weapons[equipped_weapon_id].reload_speed


func get_weapon_description_by_id(id: StringName) -> Texture2D:
	if not weapon_exists(id):
		return null
	return weapons[id].description_sprite


func get_weapon_icon_by_id(id: StringName) -> Texture2D:
	if not weapon_exists(id):
		return null
	return weapons[id].icon_sprite


func get_money_count() -> int:
	return money


func add_one_to_money() -> void:
	money += 1


func pick_up_a_weapon_by_id(id: StringName) -> void:
	if not weapon_exists(id):
		return
	weapons[id].is_owned = true


func try_to_buy_a_weapon_by_id(id: StringName) -> bool:
	if not weapon_exists(id):
		return false
	if money >= weapons[id].price and not weapons[id].is_owned:
		money -= weapons[id].price
		weapons[id].was_bought = true
		weapons[id].is_owned = true
		return true
	return false


func get_new_equipped_weapon_arms_sprite() -> SpriteFrames:
	if not weapon_exists(equipped_weapon_id):
		return null
	return weapons[equipped_weapon_id].arms_sprite


func get_all_weapons() -> Array[WeaponData]:
	var result: Array[WeaponData] = []
	for w: WeaponData in weapons.values():
		result.append(w)
	return result


func get_owned_weapons() -> Array[WeaponData]:
	var result: Array[WeaponData] = []
	for w: WeaponData in weapons.values():
		if w.is_owned:
			result.append(w)
	return result


func weapon_exists_and_is_owned(id: StringName) -> bool:
	return weapon_exists(id) and weapons[id].is_owned


func equip_a_new_weapon_by_id(id: StringName) -> void:
	if not weapon_exists_and_is_owned(id):
		return

	equipped_weapon_id = id
	new_weapon_equipped.emit()
