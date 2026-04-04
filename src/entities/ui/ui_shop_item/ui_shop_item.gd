class_name UIShopItem
extends Node2D
## UI element representing a single item entry in shop buy and sell lists.
##
## Depending on the context, the item may represent:
## - Any item available for purchase (those with a non-zero [member ItemData.buy_price]).
## - Any item available for selling (those with a non-zero [member ItemData.sell_price]).

## Stack quantity prefix shown in the sell list.
const _PREFIX_TEXT: String = "X"

@onready var _title: Label = $Title
@onready var _prefix: Label = $Prefix
@onready var _value: Label = $Value
@onready var _price: Label = $Price
@onready var _new_tag: Sprite2D = $NewTag


## Configures the item to display information for the buy list.
func setup_buy(given_name: String, price_value: int, is_new: bool) -> void:
	_title.text = given_name
	_price.text = str(price_value)
	_prefix.hide()
	_value.hide()
	_new_tag.visible = is_new


## Configures the item to display information for the sell list.
func setup_sell(given_name: String, stack_count: int, price_value: int) -> void:
	_title.text = given_name
	_prefix.text = _PREFIX_TEXT
	_value.text = str(stack_count)
	_price.text = str(price_value)
	_prefix.show()
	_value.show()
	_new_tag.hide()
