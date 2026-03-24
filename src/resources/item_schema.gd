class_name ItemSchema
extends RefCounted
## Validation bounds shared across all item-related systems.
##
## See: "res://docs/decisions/item_architecture.md"

## Regex pattern for [member ItemData.id]. Enforces snake_case: lowercase letters, digits,
## and underscores only; must start with a lowercase letter and end with a letter or digit
## (no trailing underscore). See: "res://docs/decisions/item_architecture.md"
const ID_PATTERN: String = "^[a-z]([a-z0-9_]*[a-z0-9])?$"
## Minimum length for [member ItemData.id].
const MIN_ID_LENGTH: int = 1
## Maximum length for [member ItemData.id].
const MAX_ID_LENGTH: int = 32

## Minimum length for [member ItemData.ui_name].
const MIN_UI_NAME_LENGTH: int = 1
## Maximum length for [member ItemData.ui_name].
const MAX_UI_NAME_LENGTH: int = 12

## Minimum length for [member ItemData.description].
const MIN_DESCRIPTION_LENGTH: int = 1
## Maximum length for [member ItemData.description].
const MAX_DESCRIPTION_LENGTH: int = 50

## Minimum for [member ItemData.buy_price] and [member ItemData.sell_price].
## [code]0[/code] means not buyable or not sellable respectively.
const MIN_PRICE: int = 0
## Maximum for [member ItemData.buy_price] and [member ItemData.sell_price].
const MAX_PRICE: int = 999999

## Minimum value for [member ItemData.stack_size].
const MIN_STACK: int = 1
## Maximum value for [member ItemData.stack_size].
const MAX_STACK: int = 99

## Minimum chapter. Also used as the minimum availability — both share the same scale.
const MIN_CHAPTER: int = 1
## Maximum chapter. Also used as the maximum availability — both share the same scale.
const MAX_CHAPTER: int = 4

## Sentinel assigned to non-shop items. See: "res://docs/decisions/item_architecture.md"
const AVAILABILITY_NOT_FOR_SALE: int = MAX_CHAPTER + 1

## Minimum per-axis value for [member ItemData.inventory_size] (width and height).
const MIN_SIZE_DIM: int = 1
## Maximum per-axis value for [member ItemData.inventory_size] (width and height).
const MAX_SIZE_DIM: int = 8

## Minimum value for all weapon stats (power, rate of fire, reload speed, ammo capacity).
const MIN_WEAPON_STAT: int = 0
## Maximum value for all weapon stats (power, rate of fire, reload speed, ammo capacity).
const MAX_WEAPON_STAT: int = 100
