# WeaponData
# Base Resource template for weapons.
#
# Architecture:
# - Each weapon (HANDGUN, RIFLE, etc.) has exactly ONE Resource instance per session.
# - That instance represents the live mutable runtime state.
# - It is hydrated from save data on load, mutated during gameplay,
#   and serialized into a separate save file.
#
# IMPORTANT:
# - Do NOT duplicate() weapon resources.
# - Do NOT save the .tres file via ResourceSaver.
# - The .tres acts as a static template + runtime container.
#   Persistence is handled externally.
class_name WeaponData
extends Resource

# Only meant to be set once via GUI when you instance tres and be left alone forever
@export var id: StringName
@export var arms_sprite: SpriteFrames
@export var icon_sprite: Texture2D
@export var description_sprite: Texture2D
@export var buy_page_list_item_scene: PackedScene
@export var inv_page_list_item_scene: PackedScene
@export var price: int
@export var magazine_size: int
@export var reload_speed: float

# These are meant to be hydrated on load, mutated in gameplay, dumped to disk on save
var magazine_current: int
var reserve_ammo: int
var is_owned: bool
var was_bought: bool


func can_reload() -> bool:
	return reserve_ammo > 0 and magazine_current < magazine_size


func reload() -> void:
	var needed: int = magazine_size - magazine_current
	var available: int = mini(needed, reserve_ammo)
	magazine_current += available
	reserve_ammo -= available


func try_consume_ammo() -> bool:
	if magazine_current > 0:
		magazine_current -= 1
		return true
	return false


func mark_as_owned() -> void:
	is_owned = true
	was_bought = true
