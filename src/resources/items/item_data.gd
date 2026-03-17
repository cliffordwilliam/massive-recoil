class_name ItemData
extends Resource
## Static definition for any item that can exist in the game world.
##
## Bounds are in [ItemSchema]. See: "res://docs/decisions/item_architecture.md"
##
## [b]No validation is performed here.[/b] [ItemDefinitions] constructs instances;
## [ItemValidator] enforces field constraints; [code]PlayerInventory[/code] enforces
## placement rules (stack bounds via [constant ItemSchema.MIN_STACK] and [member stack_size]).

## Type determines item behaviour and gameplay role.
enum Type {
	## E.g. First Aid Spray.
	MED,
	## E.g. Red Herb.
	COMBINABLE_MED,
	## E.g. TMP Ammo.
	AMMO,
	## E.g. Attache Case S. (Inventory size upgrades)
	INVENTORY_UPGRADE,
	## E.g. Rifle
	WEAPON,
	## E.g. Ammo Capacity Upgrade
	WEAPON_UPGRADE,
	## E.g. Green Catseye
	TREASURE,
	## E.g. Emblem (Left half)
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

var id: StringName = &""
var type: Type = Type.MED
var ui_name: String = ""
var description: String = ""
var inventory_size: Vector2i = Vector2i(1, 1)

## Price to purchase this item from the merchant. [code]0[/code] means not buyable.
var buy_price: int = 0

## Price received when selling this item to the merchant. [code]0[/code] means not sellable.
var sell_price: int = 0

## Maximum number of this item that can occupy a single inventory slot.
var stack_size: int = 1

## Earliest chapter in which this item becomes available in the merchant shop.
## Only meaningful when [member buy_price] is non-zero.
var availability: int = ItemSchema.AVAILABILITY_NOT_FOR_SALE

## Ammo type this weapon consumes. Only meaningful when [member type] is [constant Type.WEAPON].
var ammo_type: AmmoType = AmmoType.NONE
