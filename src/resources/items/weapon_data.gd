class_name WeaponData
extends Resource
## Static weapon-specific data for a [constant ItemData.Type.WEAPON] item.
##
## Held as [member ItemData.weapon_data] on weapon [ItemData] instances; [code]null[/code]
## on all non-weapon items. [ItemValidator] enforces this coupling.
##
## Immutable after [member _initialized] is set to [code]true[/code].
## [method ItemDefinitions._make_weapon_data] constructs instances;
## [ItemValidator] enforces field constraints.
##
## All stat values are integers in [[constant ItemSchema.WEAPON_STAT_MIN],
## [constant ItemSchema.WEAPON_STAT_MAX]]. Each weapon starts at its [code]_min[/code]
## value and upgrades push toward [code]_max[/code]. A [code]_upgrade_step[/code] of
## [code]0[/code] means that stat cannot be upgraded.
##
## See: "res://docs/decisions/item_architecture.md"

## Ammo type this weapon consumes.
enum AmmoType {
	## No ammo consumed — infinite-ammo weapon.
	NONE,
	## Handgun ammunition.
	HANDGUN_AMMO,
	## Submachine gun ammunition.
	SMG_AMMO,
}

## Ammo type this weapon consumes. [constant AmmoType.NONE] means infinite-ammo.
var ammo_type: AmmoType = AmmoType.NONE:
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

## Write-once. Set by [method ItemDefinitions._make_weapon_data] after all fields are assigned.
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
