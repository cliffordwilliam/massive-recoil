@icon("res://assets/images/static/icons/apparel_24dp_8DA5F3_FILL0_wght400_GRAD0_opsz24.svg")
class_name ShopItemData
extends Resource
## Static definition for a shop item.
##
## Think of this resource as a **database schema**, where each `.tres` file
## represents a single row in the table.
##
## Each item has a unique `id` used for lookups and persistence.
##
## The data stored here is **immutable design-time data**. It acts like a
## lookup table describing what the item is, while runtime state (such as
## quantity, upgrade level, or "new" flags) is stored separately.

## Unique identifier used for save/load and lookups.
@export var id: StringName

## Display name shown in shop UI.
@export var display_name: String

## Whether this item can appear in the **buy page**.
@export var can_buy: bool = false

## Whether this item can appear in the **sell page**.
@export var can_sell: bool = false

## Whether this item supports upgrades.
@export var can_upgrade: bool = false

## Price when purchasing the item.
@export var buy_price: int = 0

## Price received when selling the item.
@export var sell_price: int = 0
