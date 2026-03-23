class_name ItemData
extends Resource
## Static definition for any item that can exist in the game world.
##
## Bounds are in [ItemSchema]. See: "res://docs/decisions/item_architecture.md"
##
## Constructed and validated in [method _init]. [ItemValidator] enforces field
## constraints; [code]PlayerInventory[/code] enforces business rules.

## Type determines item behaviour and gameplay role.
enum Type {
	## E.g. First Aid, Combinable Meds.
	MED,
	## E.g. TMP Ammo.
	AMMO,
	## E.g. Inventory Size upgrades.
	INVENTORY_UPGRADE,
	## E.g. Rifle.
	WEAPON,
	## E.g. Ammo Capacity Upgrade.
	WEAPON_UPGRADE,
	## E.g. Gemstone, Crown.
	TREASURE,
	## E.g. Key Left Half, Gate Key.
	KEY,
}

## Stat targeted by a [constant Type.WEAPON_UPGRADE] item.
## [constant NONE] on all other item types (enforced by [ItemValidator]).
enum UpgradeStat {
	## Not a weapon upgrade — assigned to all non-[constant Type.WEAPON_UPGRADE] items.
	## Enforced by [ItemValidator].
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

## Unique snake_case identifier. Used as the lookup key in [ItemRegistry].
## See field invariants in "res://docs/decisions/item_architecture.md".
var id: StringName = &"":
	set(value):
		Utils.require(not _initialized, "ItemData.id: immutable after initialization")
		id = value

## Determines gameplay role and behaviour. See [enum Type].
var type: Type = Type.MED:
	set(value):
		Utils.require(not _initialized, "ItemData.type: immutable after initialization")
		type = value

## Display name shown in the inventory and shop UI.
var ui_name: String = "":
	set(value):
		Utils.require(not _initialized, "ItemData.ui_name: immutable after initialization")
		ui_name = value

## Flavour text shown in the Examine modal.
var description: String = "":
	set(value):
		Utils.require(not _initialized, "ItemData.description: immutable after initialization")
		description = value

## Grid footprint in inventory cells (columns × rows).
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
## Set by [method _init] after all fields are assigned and validated.
## Guards all fields against reassignment once set.
##
## [b]Convention:[/b] every field added to this class must include a setter that
## checks [member _initialized] to keep the immutability contract enforced.
##
## See: "res://docs/godot/can_other_mutate_prop_before_init.md"
var _initialized: bool = false:
	set(value):
		Utils.require(
			not _initialized and value,
			"ItemData._initialized: write-once — can only transition from false to true"
		)
		_initialized = value


## Constructs, validates, and freezes this [ItemData] instance.
## Crashes via [method Utils.require] on the first constraint violation.
## See: "res://docs/decisions/item_architecture.md"
# gdlint:ignore = function-arguments-number
func _init(
	given_id: StringName,
	given_type: Type,
	given_ui_name: String,
	given_description: String,
	given_inventory_size: Vector2i,
	given_buy_price: int,
	given_sell_price: int,
	given_stack_size: int,
	given_availability: int,
	given_weapon_data: WeaponData = null,
	given_upgrade_stat: UpgradeStat = UpgradeStat.NONE,
) -> void:
	self.id = given_id
	self.type = given_type
	self.ui_name = given_ui_name
	self.description = given_description
	self.inventory_size = given_inventory_size
	self.buy_price = given_buy_price
	self.sell_price = given_sell_price
	self.stack_size = given_stack_size
	self.availability = given_availability
	self.weapon_data = given_weapon_data
	self.upgrade_stat = given_upgrade_stat
	ItemValidator.validate(self)
	_initialized = true


## Returns [code]true[/code] if this item can form a stack of more than one unit.
##
## See: "res://docs/decisions/item_architecture.md"
func is_stackable() -> bool:
	return stack_size > ItemSchema.MIN_STACK


## Returns [code]true[/code] if this item has a use action in the inventory overlay.
## The enabled types and their effects are defined in "res://docs/decisions/inventory_overlay.md"
## (Use action section).
##
## [constant Type.WEAPON_UPGRADE] is excluded: it targets a specific weapon and is applied
## by dragging it onto that weapon in Move state — Use cannot resolve the target because one
## upgrade item may apply to any of several weapons in the inventory.
##
## See: "res://docs/decisions/inventory_overlay.md"
func is_usable() -> bool:
	return type in [Type.MED, Type.INVENTORY_UPGRADE, Type.WEAPON]


## Returns [code]true[/code] if this item is available for purchase in the shop.
func is_buyable() -> bool:
	return buy_price > 0


## Returns [code]true[/code] if this item can be sold to the shop.
func is_sellable() -> bool:
	return sell_price > 0
