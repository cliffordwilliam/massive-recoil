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
const MIN_SIZE_DIM: int = 1
const MAX_SIZE_DIM: int = 6
## Valid chapter range. Mirrors availability
## because chapters and item availability are the same scale and share the same value.
const MIN_CHAPTER: int = 1
const MAX_CHAPTER: int = 4
## Sentinel stored on non-shop items ([member ItemData.buy_price] == [code]0[/code]).
## Exceeds [constant MAX_CHAPTER] so [code]availability <= chapter[/code] is always
## [code]false[/code] for these items, making the filter self-enforcing without requiring
## a separate [member ItemData.buy_price] guard.
const AVAILABILITY_NOT_FOR_SALE: int = MAX_CHAPTER + 1
