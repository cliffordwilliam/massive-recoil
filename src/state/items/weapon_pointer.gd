class_name WeaponPointer
extends RefCounted
## Live stat positions for a [constant ItemData.Type.WEAPON] item instance.
##
## Held as [member ItemState.weapon_pointer] on weapon [ItemState] instances;
## [code]null[/code] on all non-weapon items. Each field is a pointer sliding
## along its corresponding [TrackData] range in [WeaponTrack].
##
## See: "res://docs/decisions/item_architecture.md"

var power: int = 0
var rate_of_fire: int = 0
var reload_speed: int = 0
var ammo_capacity: int = 0


func _init(p_power: int, p_rate_of_fire: int, p_reload_speed: int, p_ammo_capacity: int) -> void:
	power = p_power
	rate_of_fire = p_rate_of_fire
	reload_speed = p_reload_speed
	ammo_capacity = p_ammo_capacity
