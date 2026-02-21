extends Node

signal weapon_equipped

var equipped_weapon: StringName = "arms"
var weapon_stats: Dictionary = {
	"arms": {
		"sprite_frames": preload("uid://bwtavvs3i1wy2"),
	},
	"handgun": {
		"sprite_frames": preload("uid://c6ackeixi1emi"),
	},
	"rifle": {
		"sprite_frames": preload("uid://bd23x5s463v8v"),
	},
}


func equip(weapon_name: StringName) -> void:
	equipped_weapon = weapon_name
	weapon_equipped.emit()
