class_name ItemData
extends Resource
## Static definition for any item that can exist in the game world.
##
## All items — meds, ammo, weapons, upgrades, treasures, and keys — share
## this single resource type. Behavioural differences are expressed through
## the [enum Type] field and the presence or absence of prices and flags.
##
## Each resource instance represents one item definition. Multiple gameplay
## instances may reference the same definition.

## Determines item behaviour and gameplay role.
enum Type {
	## Healing consumable. Buyable and sellable.
	MED,
	## Healing ingredient found in the world. Sellable only. Combinable into stronger meds.
	COMBINABLE_MED,
	## Stackable weapon ammunition. Sellable only.
	AMMO,
	## Permanent inventory expansion. Buyable only.
	INVENTORY_UPGRADE,
	## Unique weapon. Buyable and sellable.
	WEAPON,
	## Permanent weapon stat upgrade. Buyable only.
	WEAPON_UPGRADE,
	## Valuable item found in the world. Sellable only.
	TREASURE,
	## Progression item used to unlock areas. Cannot be bought or sold.
	KEY,
}

## Ammo type a weapon consumes. Only meaningful when [member type] is [constant Type.WEAPON].
enum AmmoType {
	## No ammo (not a weapon or weapon does not use ammo).
	NONE,
	## Handgun ammunition.
	HANDGUN_AMMO,
	## Submachine gun ammunition.
	SMG_AMMO,
}

## Unique identifier used for lookups.
@export var id: StringName

## Determines item behaviour and gameplay role.
@export var type: Type

## Display name shown in UI.
@export var display_name: String

## Flavour text shown in the inspection panel.
@export var description: String

## Grid size this item occupies in the inventory.
@export var inventory_size: Vector2i = Vector2i(1, 1)

## Price to purchase this item from the merchant. [code]0[/code] means not buyable.
@export var buy_price: int = 0

## Price received when selling this item to the merchant. [code]0[/code] means not sellable.
@export var sell_price: int = 0

## Maximum number of this item that can occupy a single inventory slot.
## [code]1[/code] means not stackable.
@export var stack_size: int = 1

## Earliest chapter in which this item becomes available in the merchant shop.
## Only meaningful when [member buy_price] or [member sell_price] is non-zero.
@export var availability: int = 1

## Ammo type this weapon consumes. Only meaningful when [member type] is [constant Type.WEAPON].
@export var ammo_type: AmmoType = AmmoType.NONE
