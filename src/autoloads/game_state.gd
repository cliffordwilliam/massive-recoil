# GameState
# Single source of truth autoload for all runtime game state.
#
# Weapon architecture:
# - WeaponData resources are preloaded once and engine-cached.
# - Each weapon (handgun, rifle, etc.) has exactly one Resource instance per session.
# - These instances represent the live mutable runtime state.
# - They start empty, are hydrated from save data on load,
#   mutated during gameplay, and serialized into the save file.
#
# Important:
# - Do not duplicate() weapon resources.
# - Do not ResourceSaver.save() the .tres files.
# - The .tres is only a template container; persistence is handled separately.
#
# For more details please read this: res://docs/decisions/how_weapon_works.md
extends Node

signal new_weapon_equipped

const HANDGUN: WeaponData = preload("uid://bh7bnh8qqxn1b")
const RIFLE: WeaponData = preload("uid://bu1h08icwgww")
const HANDGUN_ID: StringName = &"handgun"
const RIFLE_ID: StringName = &"rifle"

# Player.
var money: int = 99999999 # TODO: This is dev only, please set it back to none later.
var equipped_weapon: WeaponData = null
var equipped_weapon_id: StringName = &"":
	set(value):
		if value == equipped_weapon_id:
			return

		if not weapon_exists_and_is_owned(value):
			push_warning("Attempted to equip unowned or invalid weapon: ", value)
			return

		equipped_weapon_id = value
		equipped_weapon = weapons[equipped_weapon_id]
		new_weapon_equipped.emit()
# Weapons.
var weapons: Dictionary[StringName, WeaponData] = {
	HANDGUN_ID: HANDGUN,
	RIFLE_ID: RIFLE,
}


# API that manages dynamic resource properties to be hydrated/dump to/from disk.
func get_weapon_by_id(id: StringName) -> WeaponData:
	if not weapon_exists(id):
		return null
	return weapons[id]


func get_equipped_weapon_id() -> StringName:
	return equipped_weapon_id


func weapon_exists(id: StringName) -> bool:
	return id in weapons


func get_weapon_reserve_ammo_by_id(id: StringName) -> int:
	if not weapon_exists(id):
		return 0
	return weapons[id].reserve_ammo


func equipped_weapon_can_reload() -> bool:
	if not equipped_weapon:
		return false
	return equipped_weapon.can_reload()


func reload_weapon_by_id(id: StringName) -> void:
	if not weapon_exists(id):
		return
	weapons[id].reload()


func try_consume_ammo() -> bool:
	if not equipped_weapon:
		return false
	return equipped_weapon.try_consume_ammo()


func get_equipped_weapon_is_automatic() -> bool:
	if not equipped_weapon:
		return false
	return equipped_weapon.is_automatic


func get_equipped_weapon_fire_rate() -> float:
	if not equipped_weapon:
		return 0.0
	var rate: float = equipped_weapon.fire_rate.get_value()
	# assert() crashes in debug but strips from release exports.
	# In release, a fire_rate of 0.0 would cause the fire timer to expire every frame,
	# resulting in unlimited fire rate. Early-return a safe fallback to prevent this.
	# Doc ref: docs/godot/classes/class_timer.rst — wait_time:
	# "An unstable framerate may cause the timer to end inconsistently,
	# which is especially noticeable if the wait time is lower than roughly 0.05 seconds."
	# Doc ref: docs/godot/tutorials/scripting/gdscript/gdscript_basics.rst — Assert keyword.
	if not Utils.require(rate > 0.0, "GameState: equipped weapon fire_rate must be > 0.0"):
		return 1.0
	# Clamp to the Timer's reliable minimum. Values below ~0.05 s behave inconsistently
	# because timers can only process once per physics or process frame.
	# Doc ref: docs/godot/classes/class_timer.rst — wait_time:
	# "An unstable framerate may cause the timer to end inconsistently,
	# which is especially noticeable if the wait time is lower than roughly 0.05 seconds."
	return maxf(rate, 0.05)


func get_equipped_weapon_recoil_kick() -> float:
	if not equipped_weapon:
		return 0.0
	return equipped_weapon.recoil_kick


func get_equipped_weapon_damage() -> float:
	if not equipped_weapon:
		return 0.0
	return equipped_weapon.damage.get_value()


func get_equipped_weapon_reload_speed() -> float:
	if not equipped_weapon:
		return 0.0
	return equipped_weapon.reload_speed.get_value()


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
	# A weapon picked up from loot would have was_bought true, so it does not show "new" tag.
	# This is intended. If it was picked up once, then its not new in store anymore to the player.
	weapons[id].mark_as_owned()


func try_to_buy_a_weapon_by_id(id: StringName) -> bool:
	if not weapon_exists(id):
		return false
	var weapon: WeaponData = weapons[id]
	if money >= weapon.price and not weapon.is_owned:
		money -= weapon.price
		weapon.mark_as_owned()
		return true
	return false


func get_new_equipped_weapon_arms_sprite() -> SpriteFrames:
	if not equipped_weapon:
		return null
	return equipped_weapon.arms_sprite


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
	equipped_weapon_id = id
