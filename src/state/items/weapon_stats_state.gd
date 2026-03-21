class_name WeaponStatsState
extends RefCounted
## Mutable per-slot runtime stat state for a [constant ItemData.Type.WEAPON] item instance.
##
## Held as [member ItemState.weapon_stats_state] on weapon [ItemState] instances;
## [code]null[/code] on all non-weapon items.
##
## Set by [code]PlayerInventory[/code] immediately after slot construction. Each stat
## starts at its [WeaponData] [code]_min[/code] value and is bounded by the corresponding
## [code]_max[/code] — bounds are enforced by [code]PlayerInventory[/code], not here.
##
## [method create_snapshot] produces a detached read-only copy for UI consumption.
##
## [b]No validation is performed here.[/b] [code]PlayerInventory[/code] enforces all bounds.
##
## See: "res://docs/decisions/item_architecture.md"

## Current power value. Bounded by [member WeaponData.power_min] and [member WeaponData.power_max].
##
## Guarded against mutation on snapshots.
var power: int = 0:
	set(value):
		(
			Utils
			. require(
				not is_snapshot,
				"WeaponStatsState.power: snapshot is read-only — do not mutate a detached copy",
			)
		)
		power = value

## Current rate of fire value. Bounded by [member WeaponData.rate_of_fire_min] and
## [member WeaponData.rate_of_fire_max].
##
## Guarded against mutation on snapshots.
var rate_of_fire: int = 0:
	set(value):
		(
			Utils
			. require(
				not is_snapshot,
				"WeaponStatsState.rate_of_fire: snapshot is read-only — do not mutate a detached copy",
			)
		)
		rate_of_fire = value

## Current reload speed value. Bounded by [member WeaponData.reload_speed_min] and
## [member WeaponData.reload_speed_max].
##
## Guarded against mutation on snapshots.
var reload_speed: int = 0:
	set(value):
		(
			Utils
			. require(
				not is_snapshot,
				"WeaponStatsState.reload_speed: snapshot is read-only — do not mutate a detached copy",
			)
		)
		reload_speed = value

## Current ammo capacity value. Bounded by [member WeaponData.ammo_capacity_min] and
## [member WeaponData.ammo_capacity_max].
##
## Guarded against mutation on snapshots.
var ammo_capacity: int = 0:
	set(value):
		(
			Utils
			. require(
				not is_snapshot,
				(
					"WeaponStatsState.ammo_capacity: snapshot is read-only — do not mutate a detached "
					+ "copy"
				),
			)
		)
		ammo_capacity = value

## [b]Convention:[/b] every mutable field added to this class must include its own
## snapshot guard (checking [member is_snapshot]) to keep the read-only contract enforced.
##
## Whether this instance is a detached snapshot produced by [method create_snapshot].
##
## Live slots always have this as [code]false[/code]; snapshots always [code]true[/code].
## Write-once — only the [code]false → true[/code] transition is allowed, exactly once.
var is_snapshot: bool = false:
	set(value):
		(
			Utils
			. require(
				not is_snapshot and value,
				"WeaponStatsState.is_snapshot: write-once — can only transition from false to true",
			)
		)
		is_snapshot = value


## Returns a detached copy of this state for read-only use by the UI.
##
## The copy reflects stat values at the moment of the call and will not update if the
## original slot changes. [member is_snapshot] is [code]true[/code] on the copy so call
## sites can assert the live-vs-snapshot contract at runtime.
##
## [b]Allocates a new [WeaponStatsState] on every call[/b] — use a local variable if
## you need the snapshot more than once.
func create_snapshot() -> WeaponStatsState:
	(
		Utils
		. require(
			not is_snapshot,
			(
				"WeaponStatsState.create_snapshot: cannot snapshot a snapshot — "
				+ "only live slots may produce snapshots"
			),
		)
	)

	var copy: WeaponStatsState = WeaponStatsState.new()
	copy.power = power
	copy.rate_of_fire = rate_of_fire
	copy.reload_speed = reload_speed
	copy.ammo_capacity = ammo_capacity
	copy.is_snapshot = true

	return copy
