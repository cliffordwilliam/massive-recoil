extends Node

signal weapon_equipped

# Player states
var money: int = 0
var equipped_weapon: StringName = "arms"
# Weapon states
var weapons: Dictionary[StringName, Dictionary] = {
	"arms": {
		"player_sprites": preload("uid://bwtavvs3i1wy2"),
		"is_owned": true,
	},
	"handgun": {
		"player_sprites": preload("uid://c6ackeixi1emi"),
		"thumbnail_sprite": preload("uid://8ibmk0y17sbf"),
		"buy_page_list_item_scene": preload("uid://c80k1dw0o4xun"),
		"inv_page_list_item_scene": preload("uid://cln5lsvnj1a8x"),
		"is_owned": false,
		"was_bought": false,
		"price": 5,
	},
	"rifle": {
		"player_sprites": preload("uid://bd23x5s463v8v"),
		"thumbnail_sprite": preload("uid://dj2ky63h5gknm"),
		"buy_page_list_item_scene": preload("uid://dwrd7ddvl26x3"),
		"inv_page_list_item_scene": preload("uid://dnb2k8vk62fni"),
		"is_owned": false,
		"was_bought": false,
		"price": 10,
	},
}


func equip(weapon_name: StringName) -> void:
	equipped_weapon = weapon_name
	weapon_equipped.emit()
