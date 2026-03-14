class_name UIShopItem
extends Node2D
## UI element representing a single item entry in shop-related lists.
##
## This component is used to display items in **buy** and **sell** menus.
##
## Depending on the context, the item may represent:
## - Simple meds available for purchase.
## - Weapons available for selling.
##
## The node expects several child nodes to exist in the scene tree:
## - `Title` (`Label`) – Displays the item name.
## - `Prefix` (`Label`) – Displays the stack prefix when showing quantities.
## - `Value` (`Label`) – Displays the stack count.
## - `Price` (`Label`) – Displays the price value.
## - `NewTag` (`Sprite2D`) – Displays the **NEW** tag for recently added items.
##
## Each page type uses different combinations of these visual elements.

## Tag states used to visually mark items.
enum TagType {
	NONE,
	NEW,
}

## Text content displayed in the prefix label for stacked items.
const _PREFIX_TEXT: String = "X"

## Maximum number of characters allowed for the item title.
const _MAX_TITLE_LENGTH: int = 12

## Maximum allowed value for stack counts.
const _MAX_VALUE: int = 999

## Maximum allowed value for item prices.
const _MAX_PRICE: int = 999999

@onready var _title: Label = $Title
@onready var _prefix: Label = $Prefix
@onready var _value: Label = $Value
@onready var _price: Label = $Price
@onready var _new_tag: Sprite2D = $NewTag


## Truncates [param text] to [constant _MAX_TITLE_LENGTH] characters.
## This is a safety net — item names in [code]items.json[/code] should already
## respect this limit. No ellipsis is added; truncation is silent by design.
func _sanitize_title(text: String) -> String:
	return text.substr(0, _MAX_TITLE_LENGTH)


func _sanitize_value(number: int) -> int:
	return clampi(number, 0, _MAX_VALUE)


func _sanitize_price(number: int) -> int:
	return clampi(number, 0, _MAX_PRICE)


func set_new_tag(type: TagType) -> void:
	match type:
		TagType.NONE:
			_new_tag.hide()
		TagType.NEW:
			_new_tag.show()


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
		set_new_tag(TagType.NEW)
	else:
		set_new_tag(TagType.NONE)


## Configures the item to display information for the **sell page**.
##
## Displays the item name, quantity, and sell price.
## The stack prefix `"X"` is shown to indicate item count.
func setup_sell(given_name: String, count: int, price_value: int) -> void:
	_title.text = _sanitize_title(given_name)
	_prefix.text = _PREFIX_TEXT
	_value.text = str(_sanitize_value(count))
	_price.text = str(_sanitize_price(price_value))

	_prefix.show()
	_value.show()

	set_new_tag(TagType.NONE)
