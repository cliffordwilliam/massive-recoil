class_name WeaponTrack
extends Resource
## Static weapon-specific data for a [constant ItemData.Type.WEAPON] item.
##
## Held as [member ItemData.weapon_track] on weapon [ItemData] instances; [code]null[/code]
## on all non-weapon items.
##
## See: "res://docs/decisions/item_architecture.md"

## Available ammo types a weapon can consume.
enum AmmoType {
	## Handgun ammunition.
	HANDGUN_AMMO,
	## Submachine gun ammunition.
	SMG_AMMO,
}

@export var ammo_type: AmmoType = AmmoType.HANDGUN_AMMO

@export var power: TrackData
@export var rate_of_fire: TrackData
@export var reload_speed: TrackData
@export var ammo_capacity: TrackData
