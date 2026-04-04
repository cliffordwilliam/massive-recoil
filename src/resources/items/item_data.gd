class_name ItemData
extends Resource
## Static definition for any item that can exist in the game world.
##
## See: "res://docs/decisions/item_architecture.md"

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
## [constant NONE] on all other item types.
enum UpgradeStat {
	NONE,
	POWER,
	RATE_OF_FIRE,
	RELOAD_SPEED,
	AMMO_CAPACITY,
}

@export_category("Identity")
## Unique identifier used as the lookup key in [ItemRegistry]. snake_case, 1–32 characters.
@export var id: StringName = &""
## Determines gameplay role and behaviour. See [enum Type].
@export var type: Type = Type.MED

@export_category("Display")
## Display name shown in the inventory and shop UI. 1–12 characters.
@export var ui_name: String = ""
## Flavour text shown in the Examine modal. 1–50 characters.
@export_multiline var description: String = ""
## Icon shown in UI.
@export var slot_texture: Texture2D

@export_category("Inventory")
## Grid footprint in inventory cells (columns × rows). Each axis 1–8.
@export var inventory_size: Vector2i = Vector2i(1, 1)
## Maximum number of this item that can occupy a single inventory slot. 1–99.
@export_range(1, 99) var stack_size: int = 1
## Whether this item can stack in a single inventory slot.
@export var stackable: bool = false
## Whether this item has a use action in the inventory overlay.
@export var usable: bool = false

@export_category("Shop")
## Purchase price. 0–999999.
@export_range(0, 999999) var buy_price: int = 0
## Sale price. 0–999999.
@export_range(0, 999999) var sell_price: int = 0
## Earliest chapter in which this item becomes available in the shop. 1–4.
@export_range(1, 4) var availability: int = 1
## Whether this item can be purchased from the shop.
@export var buyable: bool = false
## Whether this item can be sold to the shop.
@export var sellable: bool = false

@export_category("Weapon")
## Weapon-specific data. Non-[code]null[/code] only when [member type] is [constant Type.WEAPON].
@export var weapon_track: WeaponTrack = null
## Stat targeted by this upgrade item. [constant UpgradeStat.NONE] for all
## non-[constant Type.WEAPON_UPGRADE] items.
@export var upgrade_stat: UpgradeStat = UpgradeStat.NONE
