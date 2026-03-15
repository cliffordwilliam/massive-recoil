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


## Truncates [param text] to [constant ItemSchema.MAX_NAME_LENGTH] characters.
## Item names in [code]items.json[/code] must respect this limit — if this triggers,
## something upstream is broken.
## [br][br]
## The [method Utils.require] call is intentional: it catches violations loudly —
## [method Utils.require] uses [code]crash = true[/code] by default, so it calls
## [method OS.crash] in both debug and release. The truncation below is a no-op
## on any string that passes the check (length already within bounds), and is
## unreachable if the check fails. Its purpose is to keep all three sanitizers
## consistent in shape, not to serve as a release fallback.
func _sanitize_title(text: String) -> String:
	Utils.require(
		text.length() <= ItemSchema.MAX_NAME_LENGTH,
		(
			"UIShopItem._sanitize_title: name '%s' exceeds max length %d"
			% [text, ItemSchema.MAX_NAME_LENGTH]
		)
	)
	# substr is called unconditionally, mirroring how clampi is used in
	# _sanitize_value and _sanitize_price. GDScript's substr clamps the length
	# to the remaining string length, so calling it on a valid string (len <=
	# MAX_NAME_LENGTH) is a no-op — it returns the full string unchanged.
	# The unconditional call keeps all three sanitizers consistent and avoids
	# a redundant length branch.
	return text.substr(0, ItemSchema.MAX_NAME_LENGTH)


func _sanitize_value(number: int) -> int:
	Utils.require(
		number >= ItemSchema.MIN_STACK and number <= ItemSchema.MAX_STACK,
		(
			"UIShopItem._sanitize_value: stack_count %d out of range [%d, %d]"
			% [number, ItemSchema.MIN_STACK, ItemSchema.MAX_STACK]
		)
	)
	return clampi(number, ItemSchema.MIN_STACK, ItemSchema.MAX_STACK)


func _sanitize_price(number: int) -> int:
	Utils.require(
		number >= ItemSchema.MIN_PRICE and number <= ItemSchema.MAX_PRICE,
		(
			"UIShopItem._sanitize_price: price %d out of range [%d, %d]"
			% [number, ItemSchema.MIN_PRICE, ItemSchema.MAX_PRICE]
		)
	)
	return clampi(number, ItemSchema.MIN_PRICE, ItemSchema.MAX_PRICE)


## Configures the item to display information for the **buy page**.
##
## Displays the item name and purchase price.
## Stack-related UI elements are hidden.
func setup_buy(
	given_name: String,
	price_value: int,
	is_new: bool,
) -> void:
	_title.text = _sanitize_title(given_name)
	_price.text = str(_sanitize_price(price_value))

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
	_title.text = _sanitize_title(given_name)
	_prefix.text = _PREFIX_TEXT
	_value.text = str(_sanitize_value(stack_count))
	_price.text = str(_sanitize_price(price_value))

	_prefix.show()
	_value.show()

	# NEW badge is buy-side only — it clears when the player purchases the item.
	_new_tag.hide()
