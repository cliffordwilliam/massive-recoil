class_name UIShopItem
extends Node2D
## UI element representing a single item entry in shop-related lists.
##
## This component is used to display items in **buy**, **sell**, and **upgrade**
## menus. The same visual element adapts depending on the page configuration.
##
## Depending on the context, the item may represent:
## - Ammunition or items available for purchase.
## - Inventory items available for selling.
## - Equipment upgrades that can be bought.
##
## The node expects several child nodes to exist in the scene tree:
## - `Title` (`Label`) – Displays the item name.
## - `Prefix` (`Label`) – Displays the stack prefix when showing quantities.
## - `Value` (`Label`) – Displays stack count or upgrade level.
## - `Price` (`Label`) – Displays the price value.
## - `Tag` (`Sprite2D`) – Displays status tags such as **NEW** or **SOLD OUT**.
##
## Each page type uses different combinations of these visual elements.

## Tag states used to visually mark items.
enum TagType {
	## No tag is displayed.
	NONE,
	## Item is marked as newly available.
	NEW,
	## Item is unavailable or sold out.
	SOLD_OUT,
}

## Text content displayed in the prefix label for stacked items.
const _PREFIX_TEXT: String = "X"

## Frame index used for the **NEW** tag.
const _TAG_FRAME_NEW: int = 0

## Frame index used for the **SOLD OUT** tag.
const _TAG_FRAME_SOLD_OUT: int = 1

## Maximum number of characters allowed for the item title.
const _MAX_TITLE_LENGTH: int = 12

## Maximum allowed value for quantity or level values.
const _MAX_VALUE: int = 999

## Maximum allowed value for item prices.
const _MAX_PRICE: int = 999999

## Label used to render the item title.
@onready var _title: Label = $Title

## Optional label used to render the `"X"` prefix for stacked items.
@onready var _prefix: Label = $Prefix

## Optional label used to render the stacked item amount or upgrade level.
@onready var _value: Label = $Value

## Optional label used to render the item price.
@onready var _price: Label = $Price

## Sprite used to display the item tag (NEW or SOLD OUT).
@onready var _tag: Sprite2D = $Tag


## Trims the provided title so it does not exceed `_MAX_TITLE_LENGTH`.
func _sanitize_title(text: String) -> String:
	return text.substr(0, _MAX_TITLE_LENGTH)


## Clamps a numeric value to the allowed range for stack counts or levels.
func _sanitize_value(number: int) -> int:
	return clampi(number, 0, _MAX_VALUE)


## Clamps a price to the allowed range defined by `_MAX_PRICE`.
func _sanitize_price(number: int) -> int:
	return clampi(number, 0, _MAX_PRICE)


## Sets the visual tag state for the item.
##
## Depending on the provided type, this function will show the tag,
## assign the correct frame, or hide the tag entirely.
func set_tag(type: TagType) -> void:
	match type:
		TagType.NONE:
			_tag.hide()
		TagType.NEW:
			_tag.frame = _TAG_FRAME_NEW
			_tag.show()
		TagType.SOLD_OUT:
			_tag.frame = _TAG_FRAME_SOLD_OUT
			_tag.show()


## Configures the item to display information for the **buy page**.
##
## Displays the item name and purchase price.
## Stack-related UI elements are hidden.
##
## - `given_name` is the item name.
## - `price_value` is the purchase price.
## - `is_new` determines if the item should display a **NEW** tag.
## - `sold_out` determines if the item should display a **SOLD OUT** tag.
func setup_buy(given_name: String, price_value: int, is_new: bool, sold_out: bool) -> void:
	_title.text = _sanitize_title(given_name)
	_price.text = str(_sanitize_price(price_value))

	_prefix.hide()
	_value.hide()

	if sold_out:
		set_tag(TagType.SOLD_OUT)
	elif is_new:
		set_tag(TagType.NEW)
	else:
		set_tag(TagType.NONE)


## Configures the item to display information for the **sell page**.
##
## Displays the item name, quantity, and sell price.
## The stack prefix `"X"` is shown to indicate item count.
##
## - `given_name` is the item name.
## - `count` is the number of items in the stack.
## - `price_value` is the sell price.
func setup_sell(given_name: String, count: int, price_value: int) -> void:
	_title.text = _sanitize_title(given_name)
	_prefix.text = _PREFIX_TEXT
	_value.text = str(_sanitize_value(count))
	_price.text = str(_sanitize_price(price_value))

	_prefix.show()
	_value.show()

	set_tag(TagType.NONE)


## Configures the item to display information for the **upgrade page**.
##
## Displays the item name, upgrade level, and upgrade price.
## The prefix label is hidden while the value label is used for level display.
##
## - `given_name` is the upgrade name.
## - `level` is the current upgrade level.
## - `price_value` is the upgrade cost.
## - `is_new` determines if the upgrade should be marked as **NEW**.
func setup_upgrade(given_name: String, level: int, price_value: int, is_new: bool) -> void:
	_title.text = _sanitize_title(given_name)
	_value.text = str(_sanitize_value(level))
	_price.text = str(_sanitize_price(price_value))

	_prefix.hide()
	_value.show()

	set_tag(TagType.NEW if is_new else TagType.NONE)
