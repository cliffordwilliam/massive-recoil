class_name ItemData
extends Resource
## Static definition for any item that can exist in the game world.
##
## Bounds are in [ItemSchema]. See: "res://docs/decisions/item_architecture.md"
##
## [b]No validation is performed here.[/b] [ItemDefinitions] constructs instances;
## [ItemValidator] enforces field constraints; [code]PlayerInventory[/code] enforces
## business rules.

## Type determines item behaviour and gameplay role.
enum Type {
	## E.g. First Aid Spray, Red Herb.
	MED,
	## E.g. TMP Ammo.
	AMMO,
	## E.g. Attache Case S. (Inventory size upgrades).
	INVENTORY_UPGRADE,
	## E.g. Rifle.
	WEAPON,
	## E.g. Ammo Capacity Upgrade.
	WEAPON_UPGRADE,
	## E.g. Green Catseye, Beerstein.
	TREASURE,
	## E.g. Emblem (Left half), Insignia Key.
	KEY,
}

## Stat targeted by a [constant Type.WEAPON_UPGRADE] item.
## [constant NONE] on all other item types (enforced by [ItemValidator]).
enum UpgradeStat {
	## Not a weapon upgrade — assigned to all non-[constant Type.WEAPON_UPGRADE] items.
	NONE,
	## Targets weapon power.
	POWER,
	## Targets weapon rate of fire.
	RATE_OF_FIRE,
	## Targets weapon reload speed.
	RELOAD_SPEED,
	## Targets weapon ammo capacity.
	AMMO_CAPACITY,
}

var id: StringName = &"":
	set(value):
		Utils.require(not _initialized, "ItemData.id: immutable after initialization")
		id = value

var type: Type = Type.MED:
	set(value):
		Utils.require(not _initialized, "ItemData.type: immutable after initialization")
		type = value

var ui_name: String = "":
	set(value):
		Utils.require(not _initialized, "ItemData.ui_name: immutable after initialization")
		ui_name = value

var description: String = "":
	set(value):
		Utils.require(not _initialized, "ItemData.description: immutable after initialization")
		description = value

var inventory_size: Vector2i = Vector2i(1, 1):
	set(value):
		Utils.require(not _initialized, "ItemData.inventory_size: immutable after initialization")
		inventory_size = value

## Price to purchase this item from the shop. [code]0[/code] means not buyable.
var buy_price: int = 0:
	set(value):
		Utils.require(not _initialized, "ItemData.buy_price: immutable after initialization")
		buy_price = value

## Price received when selling this item to the shop. [code]0[/code] means not sellable.
var sell_price: int = 0:
	set(value):
		Utils.require(not _initialized, "ItemData.sell_price: immutable after initialization")
		sell_price = value

## Maximum number of this item that can occupy a single inventory slot.
var stack_size: int = 1:
	set(value):
		Utils.require(not _initialized, "ItemData.stack_size: immutable after initialization")
		stack_size = value

## Earliest chapter in which this item becomes available in the shop.
## See field invariants in "res://docs/decisions/item_architecture.md".
var availability: int = ItemSchema.AVAILABILITY_NOT_FOR_SALE:
	set(value):
		Utils.require(not _initialized, "ItemData.availability: immutable after initialization")
		availability = value

## Weapon-specific data. Non-[code]null[/code] only when [member type] is
## [constant Type.WEAPON]. Enforced by [ItemValidator].
## See: "res://docs/decisions/item_architecture.md"
var weapon_data: WeaponData = null:
	set(value):
		Utils.require(not _initialized, "ItemData.weapon_data: immutable after initialization")
		weapon_data = value

## Stat targeted by this upgrade item. [constant UpgradeStat.NONE] for all
## non-[constant Type.WEAPON_UPGRADE] items. Enforced by [ItemValidator].
## See: "res://docs/decisions/item_architecture.md"
var upgrade_stat: UpgradeStat = UpgradeStat.NONE:
	set(value):
		Utils.require(not _initialized, "ItemData.upgrade_stat: immutable after initialization")
		upgrade_stat = value

## Write-once — only the [code]false → true[/code] transition is allowed.
## Set by [method ItemDefinitions._make] after all fields are assigned and validated.
## Guards all fields against reassignment once set.
##
## [b]Convention:[/b] every field added to this class must include a setter that
## checks [member _initialized] to keep the immutability contract enforced.
var _initialized: bool = false:
	set(value):
		Utils.require(
			not _initialized and value,
			"ItemData._initialized: write-once — can only transition from false to true"
		)
		_initialized = value


## Returns [code]true[/code] if this item can form a stack of more than one unit.
func is_stackable() -> bool:
	return stack_size > ItemSchema.MIN_STACK


## Returns [code]true[/code] if this item has a use action in the inventory overlay.
##
## Enabled for [constant Type.MED], [constant Type.INVENTORY_UPGRADE], and [constant Type.WEAPON].
## All other types have no use action and the Use button should be disabled.
func is_usable() -> bool:
	return type in [Type.MED, Type.INVENTORY_UPGRADE, Type.WEAPON]


## Returns [code]true[/code] if this item is available for purchase in the shop.
func is_buyable() -> bool:
	return buy_price > 0


## Returns [code]true[/code] if this item can be sold to the shop.
func is_sellable() -> bool:
	return sell_price > 0
