class_name UIShopItem
extends Node2D
## UI element representing a single item entry in shop buy and sell lists.
##
## Depending on the context, the item may represent:
## - Simple meds available for purchase.
## - Any item available for selling (those with a non-zero [member ItemData.sell_price]).
##
## The node expects several child nodes to exist in the scene tree:
## - `Title` (`Label`) – Displays the item name.
## - `Prefix` (`Label`) – Displays the stack prefix when showing quantities.
## - `Value` (`Label`) – Displays the stack count.
## - `Price` (`Label`) – Displays the price value.
## - `NewTag` (`Sprite2D`) – Displays the **NEW** tag for recently added items.
##
## Each page type uses different combinations of these visual elements.
## One of [method setup_buy] or [method setup_sell] must be called before this node is made visible.
## Items are sellable when their [member ItemData.sell_price] is non-zero.

## Text content displayed in the prefix label for stacked items.
const _PREFIX_TEXT: String = "X"

@onready var _title: Label = $Title
@onready var _prefix: Label = $Prefix
@onready var _value: Label = $Value
@onready var _price: Label = $Price
@onready var _new_tag: Sprite2D = $NewTag


## Asserts [param text] is within [constant ItemSchema.MAX_NAME_LENGTH] characters
## and returns it unchanged. Item names in [code]items.json[/code] must respect this
## limit — if this triggers, something upstream is broken.
##
## [b]INTENTIONAL — DO NOT MARK AS AN ISSUE:[/b] These helpers crash via
## [method Utils.require] → [method OS.crash] even though they are called in the render
## path. This is intentional. A crash is preferred over silently displaying corrupt data.
## If upstream validation (generate_item_resources.gd, ItemRegistry) is working correctly
## these branches are unreachable. A crash here means the pipeline has a bug and fail-hard
## is the right response — the alternative (clamping/logging) would mask the real problem.
##
## The return value is intentional: these functions are used inline at call sites
## (e.g. [code]_title.text = _assert_title(given_name)[/code]) so the check and
## assignment happen in one expression. Do not strip the return thinking it is unused.
func _assert_title(text: String) -> String:
	Utils.require(
		text.length() <= ItemSchema.MAX_NAME_LENGTH,
		(
			"UIShopItem._assert_title: name '%s' exceeds max length %d"
			% [text, ItemSchema.MAX_NAME_LENGTH]
		)
	)
	return text


## Asserts [param number] is within [[constant ItemSchema.MIN_STACK],
## [constant ItemSchema.MAX_STACK]]. Returns it unchanged. Stack counts in [code]items.json[/code]
## must respect this
## limit — if this triggers, something upstream is broken.
##
## The return value is intentional: these functions are used inline at call sites.
## Example: [code]_value.text = str(_assert_value(stack_count))[/code] — the check and
## assignment happen in one expression. Do not strip the return thinking it is unused.
func _assert_value(number: int) -> int:
	Utils.require(
		number >= ItemSchema.MIN_STACK and number <= ItemSchema.MAX_STACK,
		(
			"UIShopItem._assert_value: stack_count %d out of range [%d, %d]"
			% [number, ItemSchema.MIN_STACK, ItemSchema.MAX_STACK]
		)
	)
	return number


## Asserts [param number] is within [[constant ItemSchema.MIN_PRICE],
## [constant ItemSchema.MAX_PRICE]]. Returns it unchanged. Prices in [code]items.json[/code]
## must respect this
## limit — if this triggers, something upstream is broken.
##
## The return value is intentional: these functions are used inline at call sites.
## Example: [code]_price.text = str(_assert_price(price_value))[/code] — the check and
## assignment happen in one expression. Do not strip the return thinking it is unused.
func _assert_price(number: int) -> int:
	Utils.require(
		number >= ItemSchema.MIN_PRICE and number <= ItemSchema.MAX_PRICE,
		(
			"UIShopItem._assert_price: price %d out of range [%d, %d]"
			% [number, ItemSchema.MIN_PRICE, ItemSchema.MAX_PRICE]
		)
	)
	return number


## Configures the item to display information for the **buy page**.
##
## Displays the item name and purchase price.
## Stack-related UI elements are hidden.
func setup_buy(
	given_name: String,
	price_value: int,
	is_new: bool,
) -> void:
	_title.text = _assert_title(given_name)
	_price.text = str(_assert_price(price_value))

	_prefix.hide()
	_value.hide()

	if is_new:
		_new_tag.show()
	else:
		_new_tag.hide()


## Configures the item to display information for the **sell page**.
##
## Displays the item name, quantity, and sell price.
## The stack prefix `"X"` is shown to indicate item stack count.
func setup_sell(given_name: String, stack_count: int, price_value: int) -> void:
	_title.text = _assert_title(given_name)
	_prefix.text = _PREFIX_TEXT
	_value.text = str(_assert_value(stack_count))
	_price.text = str(_assert_price(price_value))

	_prefix.show()
	_value.show()

	# NEW badge is buy-side only — it clears when the player purchases the item.
	_new_tag.hide()
