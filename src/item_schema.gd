class_name ItemSchema
extends RefCounted
## Schema invariants shared across all item-related systems.
##
## These bounds are enforced at every stage of the data pipeline:
## [br]- [code]generate_item_resources.gd[/code] validates JSON before writing [code].tres[/code].
## [br]- [code]UIShopItem[/code] sanitizes display values at render time.
## [br]- [code]PlayerInventory[/code] clamps stack counts on placement and load.
## [br]- [code]GameState[/code] validates chapter range on load.

const MAX_NAME_LENGTH: int = 12
const MAX_DESCRIPTION_LENGTH: int = 50
const MIN_PRICE: int = 0
const MAX_PRICE: int = 999999
const MIN_STACK: int = 1
const MAX_STACK: int = 999
const MIN_AVAILABILITY: int = 1
const MAX_AVAILABILITY: int = 4
const MIN_SIZE_DIM: int = 1
const MAX_SIZE_DIM: int = 6
## Valid chapter range. Mirrors [constant MIN_AVAILABILITY] / [constant MAX_AVAILABILITY]
## because chapters and item availability are the same scale.
const MIN_CHAPTER: int = MIN_AVAILABILITY
const MAX_CHAPTER: int = MAX_AVAILABILITY
