class_name WeaponData
extends Resource
## Static weapon-specific data for a [constant ItemData.Type.WEAPON] item.
##
## Held as [member ItemData.weapon_data] on weapon [ItemData] instances; [code]null[/code]
## on all non-weapon items. [ItemValidator] enforces this coupling.
##
## Immutable after [member _initialized] is set to [code]true[/code].
## Constructed in [method _init]; [ItemValidator] enforces field constraints
## when the parent [ItemData] is validated.
##
## All stat values are integers in [[constant ItemSchema.MIN_WEAPON_STAT],
## [constant ItemSchema.MAX_WEAPON_STAT]]. Each weapon starts at its [code]_min[/code]
## value and upgrades push toward [code]_max[/code]. A [code]_upgrade_step[/code] of
## [code]0[/code] means that stat cannot be upgraded.
##
## See: "res://docs/decisions/item_architecture.md"

## Available ammo types a weapon can consume.
enum AmmoType {
	## Handgun ammunition.
	HANDGUN_AMMO,
	## Submachine gun ammunition.
	SMG_AMMO,
}

## Ammo type this weapon consumes.
var ammo_type: AmmoType = AmmoType.HANDGUN_AMMO:
	set(value):
		Utils.require(not _initialized, "WeaponData.ammo_type: immutable after initialization")
		ammo_type = value

## Minimum (starting) power value.
var power_min: int = 0:
	set(value):
		Utils.require(not _initialized, "WeaponData.power_min: immutable after initialization")
		power_min = value

## Maximum power value. Upgrades cannot exceed this.
var power_max: int = 0:
	set(value):
		Utils.require(not _initialized, "WeaponData.power_max: immutable after initialization")
		power_max = value

## Amount added per power upgrade. [code]0[/code] means this stat cannot be upgraded.
var power_upgrade_step: int = 0:
	set(value):
		Utils.require(
			not _initialized, "WeaponData.power_upgrade_step: immutable after initialization"
		)
		power_upgrade_step = value

## Minimum (starting) rate of fire value.
var rate_of_fire_min: int = 0:
	set(value):
		Utils.require(
			not _initialized, "WeaponData.rate_of_fire_min: immutable after initialization"
		)
		rate_of_fire_min = value

## Maximum rate of fire value. Upgrades cannot exceed this.
var rate_of_fire_max: int = 0:
	set(value):
		Utils.require(
			not _initialized, "WeaponData.rate_of_fire_max: immutable after initialization"
		)
		rate_of_fire_max = value

## Amount added per rate of fire upgrade. [code]0[/code] means this stat cannot be upgraded.
var rate_of_fire_upgrade_step: int = 0:
	set(value):
		(
			Utils
			. require(
				not _initialized,
				"WeaponData.rate_of_fire_upgrade_step: immutable after initialization",
			)
		)
		rate_of_fire_upgrade_step = value

## Minimum (starting) reload speed value.
var reload_speed_min: int = 0:
	set(value):
		Utils.require(
			not _initialized, "WeaponData.reload_speed_min: immutable after initialization"
		)
		reload_speed_min = value

## Maximum reload speed value. Upgrades cannot exceed this.
var reload_speed_max: int = 0:
	set(value):
		Utils.require(
			not _initialized, "WeaponData.reload_speed_max: immutable after initialization"
		)
		reload_speed_max = value

## Amount added per reload speed upgrade. [code]0[/code] means this stat cannot be upgraded.
var reload_speed_upgrade_step: int = 0:
	set(value):
		(
			Utils
			. require(
				not _initialized,
				"WeaponData.reload_speed_upgrade_step: immutable after initialization",
			)
		)
		reload_speed_upgrade_step = value

## Minimum (starting) ammo capacity value.
var ammo_capacity_min: int = 0:
	set(value):
		Utils.require(
			not _initialized, "WeaponData.ammo_capacity_min: immutable after initialization"
		)
		ammo_capacity_min = value

## Maximum ammo capacity value. Upgrades cannot exceed this.
var ammo_capacity_max: int = 0:
	set(value):
		Utils.require(
			not _initialized, "WeaponData.ammo_capacity_max: immutable after initialization"
		)
		ammo_capacity_max = value

## Amount added per ammo capacity upgrade. [code]0[/code] means this stat cannot be upgraded.
var ammo_capacity_upgrade_step: int = 0:
	set(value):
		(
			Utils
			. require(
				not _initialized,
				"WeaponData.ammo_capacity_upgrade_step: immutable after initialization",
			)
		)
		ammo_capacity_upgrade_step = value

## Write-once. Set by [method _init] after all fields are assigned.
## Guards all fields against reassignment once set.
##
## [b]Convention:[/b] every field added to this class must include a setter that
## checks [member _initialized] to keep the immutability contract enforced.
var _initialized: bool = false:
	set(value):
		(
			Utils
			. require(
				not _initialized and value,
				"WeaponData._initialized: write-once — can only transition from false to true",
			)
		)
		_initialized = value


## Constructs and freezes this [WeaponData] instance.
## [ItemValidator] validates all fields when the parent [ItemData] is validated.
## See: "res://docs/decisions/item_architecture.md"
# gdlint:ignore = function-arguments-number
func _init(
	given_ammo_type: AmmoType,
	given_power_min: int,
	given_power_max: int,
	given_power_upgrade_step: int,
	given_rate_of_fire_min: int,
	given_rate_of_fire_max: int,
	given_rate_of_fire_upgrade_step: int,
	given_reload_speed_min: int,
	given_reload_speed_max: int,
	given_reload_speed_upgrade_step: int,
	given_ammo_capacity_min: int,
	given_ammo_capacity_max: int,
	given_ammo_capacity_upgrade_step: int,
) -> void:
	self.ammo_type = given_ammo_type
	self.power_min = given_power_min
	self.power_max = given_power_max
	self.power_upgrade_step = given_power_upgrade_step
	self.rate_of_fire_min = given_rate_of_fire_min
	self.rate_of_fire_max = given_rate_of_fire_max
	self.rate_of_fire_upgrade_step = given_rate_of_fire_upgrade_step
	self.reload_speed_min = given_reload_speed_min
	self.reload_speed_max = given_reload_speed_max
	self.reload_speed_upgrade_step = given_reload_speed_upgrade_step
	self.ammo_capacity_min = given_ammo_capacity_min
	self.ammo_capacity_max = given_ammo_capacity_max
	self.ammo_capacity_upgrade_step = given_ammo_capacity_upgrade_step
	_initialized = true
