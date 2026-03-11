## UI element representing a single item entry in shop-related lists.
##
## This component is used to display items in **buy**, **sell**, and **upgrade**
## menus. The same visual element adapts depending on the page configuration.
##
## The item may represent:
## - Ammunition or items available for purchase.
## - Inventory items available for selling.
## - Equipment upgrades that can be bought.
##
## The node expects several child nodes to exist in the scene tree:
## - `Title` (`Label`) – Displays the item name.
## - `X` (`Label`) – Displays the stack prefix when showing quantities.
## - `Value` (`Label`) – Displays stack count or upgrade level.
## - `Price` (`Label`) – Displays the price value.
## - `Tag` (`Sprite2D`) – Displays status tags such as **NEW** or **SOLD OUT**.
##
## Each page type uses different combinations of these visual elements.
@icon("res://assets/images/static/icons/shopping_bag_24dp_8DA5F3_FILL0_wght400_GRAD0_opsz24.svg")
class_name UIShopItem
extends Node2D

## Tag states used to visually mark items.
enum TagType {
	## No tag is displayed.
	NONE,
	## Item is marked as newly available.
	NEW,
	## Item is unavailable or sold out.
	SOLD_OUT
}

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
@onready var title: Label = $Title

## Optional label used to render the `"X"` prefix for stacked items.
@onready var prefix: Label = $Prefix

## Optional label used to render the stacked item amount or upgrade level.
@onready var value: Label = $Value

## Optional label used to render the item price.
@onready var price: Label = $Price

## Sprite used to display the item tag (NEW or SOLD OUT).
@onready var tag: Sprite2D = $Tag


## Trims the provided title so it does not exceed the maximum length.
func _sanitize_title(text: String) -> String:
	return text.substr(0, _MAX_TITLE_LENGTH)


## Clamps a numeric value so it stays within the allowed range.
func _sanitize_value(number: int) -> int:
	return clamp(number, 0, _MAX_VALUE)


## Clamps a price so it stays within the allowed price range.
func _sanitize_price(number: int) -> int:
	return clamp(number, 0, _MAX_PRICE)


## Sets the visual tag state for the item.
##
## Depending on the provided type, this function will show the tag,
## assign the correct frame, or hide the tag entirely.
func set_tag(type: TagType) -> void:
	match type:
		TagType.NONE:
			tag.hide()
		TagType.NEW:
			tag.frame = _TAG_FRAME_NEW
			tag.show()
		TagType.SOLD_OUT:
			tag.frame = _TAG_FRAME_SOLD_OUT
			tag.show()


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
	title.text = _sanitize_title(given_name)
	price.text = str(_sanitize_price(price_value))

	prefix.hide()
	value.hide()

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
	title.text = _sanitize_title(given_name)
	prefix.text = "X"
	value.text = str(_sanitize_value(count))
	price.text = str(_sanitize_price(price_value))

	prefix.show()
	value.show()

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
	title.text = _sanitize_title(given_name)
	value.text = str(_sanitize_value(level))
	price.text = str(_sanitize_price(price_value))

	prefix.hide()
	value.show()

	set_tag(TagType.NEW if is_new else TagType.NONE)
