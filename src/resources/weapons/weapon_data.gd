# WeaponData
# Base Resource template for weapons.
#
# Architecture:
# - Each weapon (handgun, rifle, etc.) has exactly one Resource instance per session.
# - That instance represents the live mutable runtime state.
# - It is hydrated from save data on load, mutated during gameplay,
#   and serialized into a separate save file.
#
# Important:
# - Do not duplicate() weapon resources.
# - Do not save the .tres file via ResourceSaver.
# - The .tres acts as a static template + runtime container.
#   Persistence is handled externally.
#
# For more details please read this: res://docs/decisions/how_weapon_works.md
class_name WeaponData
extends Resource

# Only meant to be set once via GUI when you instance tres and be left alone forever.
@export var id: StringName
@export var arms_sprite: SpriteFrames
@export var icon_sprite: Texture2D
@export var description_sprite: Texture2D
@export var buy_page_list_item_scene: PackedScene
@export var inv_page_list_item_scene: PackedScene
@export var price: int
@export var magazine_size: UpgradeListData
@export var reload_speed: UpgradeListData
@export var damage: UpgradeListData
@export var fire_rate: UpgradeListData
@export var is_automatic: bool
@export var recoil_kick: float

# These are meant to be hydrated on load, mutated in gameplay, dumped to disk on save.
var magazine_current: int
var reserve_ammo: int
var is_owned: bool
var was_bought: bool


# API for GameState to use
func can_reload() -> bool:
	var has_reserve_ammo: bool = reserve_ammo > 0
	var magazine_is_not_full: bool = magazine_current < int(magazine_size.get_value())
	return has_reserve_ammo and magazine_is_not_full


func reload() -> void:
	var requested: int = int(magazine_size.get_value()) - magazine_current
	var given: int = mini(requested, reserve_ammo)
	magazine_current += given
	reserve_ammo -= given


func try_consume_ammo() -> bool:
	if magazine_current > 0:
		magazine_current -= 1
		return true
	return false


func mark_as_owned() -> void:
	is_owned = true
	was_bought = true
