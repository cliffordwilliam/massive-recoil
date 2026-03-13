class_name ShopItemData
extends ItemData
## Base class for items that can appear in the merchant shop.
##
## The shop system supports several categories of items:
##
## | Item                          | Description                                                |
## |-------------------------------|------------------------------------------------------------|
## | Health potions                | Restore player health.                                     |
## | Combinable health ingredients | Can only be sold. Can be combined to create other items.   |
## | Weapon ammunition             | Stackable items used by weapons.                           |
## | Inventory size upgrades       | Increase inventory capacity. Cannot be sold.               |
## | Weapons                       | Unique items per gameplay session.                         |
## | Weapon upgrades               | Upgrade nodes for weapons (power, etc). Cannot be sold.    |
## | Simple treasures              | Can only be sold. Do not occupy inventory space.           |
## | Complex treasures             | Similar to simple treasures but allow gem combinations.    |
##
## Subclasses should override only the pricing methods relevant to their behavior.
##
## Returning `0` means the operation is not supported for the item.
##
## - Override [get_buy_price] if the merchant sells the item.
## - Override [get_sell_price] if the player can sell the item.

## Grid size this item occupies in the inventory.
## A size of `(0, 0)` means the item does not occupy any grid space.
@export var inventory_size: Vector2i = Vector2i.ZERO

## Maximum number of items that can be stacked in one inventory slot.
@export var stack_size: int = 1

## Earliest chapter in which this item becomes available in the shop.
@export var availability: int = 1


## Returns the price to purchase this item from the merchant.
## `0` means the item cannot be bought.
func get_buy_price() -> int:
	return 0


## Returns the price received when selling this item to the merchant.
## `0` means the item cannot be sold.
func get_sell_price() -> int:
	return 0
