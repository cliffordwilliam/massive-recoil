extends Node

signal weapon_equipped

# Player states
var money: int = 0
var equipped_weapon: StringName = "arms"
# Weapon states
var weapons: Dictionary = {
	"arms": {
		"player_sprites": preload("uid://bwtavvs3i1wy2"),
		"location": "none",
	},
	"handgun": {
		"player_sprites": preload("uid://c6ackeixi1emi"),
		"thumbnail_sprite": preload("uid://8ibmk0y17sbf"),
		"buy_page_list_item_scene": preload("uid://c7vfk6kv8khqq"),
		"location": "shop",
	},
	"rifle": {
		"player_sprites": preload("uid://bd23x5s463v8v"),
		"thumbnail_sprite": preload("uid://dj2ky63h5gknm"),
		"buy_page_list_item_scene": preload("uid://c8ix6738cu5kk"),
		"location": "shop",
	},
}


func equip(weapon_name: StringName) -> void:
	equipped_weapon = weapon_name
	weapon_equipped.emit()
