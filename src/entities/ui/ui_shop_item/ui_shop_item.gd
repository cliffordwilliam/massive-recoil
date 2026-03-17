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
## Exactly one of [method setup_buy] or [method setup_sell] is called per instance,
## determined by the owning [UIShopItemList] render mode, which is fixed at scene
## configuration time and never changes at runtime.

const _PREFIX_TEXT: String = "X"

@onready var _title: Label = $Title
@onready var _prefix: Label = $Prefix
@onready var _value: Label = $Value
@onready var _price: Label = $Price
@onready var _new_tag: Sprite2D = $NewTag


## Asserts [param text] is within [constant ItemSchema.MAX_NAME_LENGTH] characters.
## Crashes if violated — a trigger here means [ItemValidator] has a bug, not a
## recoverable condition. Returns [param text] unchanged for inline assignment:
## [code]_title.text = _assert_title(given_name)[/code]
func _assert_title(text: String) -> String:
	Utils.require(
		text.length() <= ItemSchema.MAX_NAME_LENGTH,
		(
			"UIShopItem._assert_title: name '%s' exceeds max length %d"
			% [text, ItemSchema.MAX_NAME_LENGTH]
		)
	)
	return text


## Same pattern as [method _assert_title].
## Asserts [param number] is within [[constant ItemSchema.MIN_STACK],
## [constant ItemSchema.MAX_STACK]].
func _assert_value(number: int) -> int:
	Utils.require(
		number >= ItemSchema.MIN_STACK and number <= ItemSchema.MAX_STACK,
		(
			"UIShopItem._assert_value: stack_count %d out of range [%d, %d]"
			% [number, ItemSchema.MIN_STACK, ItemSchema.MAX_STACK]
		)
	)
	return number


## Same pattern as [method _assert_title].
## Asserts [param number] is within [[constant ItemSchema.MIN_PRICE],
## [constant ItemSchema.MAX_PRICE]].
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
