class_name ItemSchema
extends RefCounted
## Validation bounds shared across all item-related systems.
##
## See: "res://docs/decisions/item_architecture.md"

const MIN_NAME_LENGTH: int = 1
const MAX_NAME_LENGTH: int = 12

const MIN_DESCRIPTION_LENGTH: int = 1
const MAX_DESCRIPTION_LENGTH: int = 50

const MIN_PRICE: int = 0
const MAX_PRICE: int = 999999

const MIN_STACK: int = 1
const MAX_STACK: int = 999

## Per-axis bounds for [member ItemData.inventory_size] (width and height).
const MIN_SIZE_DIM: int = 1
const MAX_SIZE_DIM: int = 8

## Chapter range. Also used as the availability scale — both share the same values.
const MIN_CHAPTER: int = 1
const MAX_CHAPTER: int = 4

## Regex pattern for [member ItemData.id]. Enforces snake_case: lowercase letters, digits,
## and underscores only; must start and end with a letter or digit (no trailing underscore).
const ID_PATTERN: String = "^[a-z]([a-z0-9_]*[a-z0-9])?$"
const MIN_ID_LENGTH: int = 1
const MAX_ID_LENGTH: int = 32

## Sentinel assigned to non-shop items. See: "res://docs/decisions/item_architecture.md"
const AVAILABILITY_NOT_FOR_SALE: int = MAX_CHAPTER + 1

## Global range for all weapon stat values (power, rate of fire, reload speed, ammo capacity).
const WEAPON_STAT_MIN: int = 0
const WEAPON_STAT_MAX: int = 100
