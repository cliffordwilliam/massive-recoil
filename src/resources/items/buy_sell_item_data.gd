class_name BuySellItemData
extends ShopItemData
## Item that can be both purchased from and sold to the merchant.
##
## Used for consumables such as medkits, bandages, and antiseptic vials.

## Price to purchase this item from the merchant.
@export var buy_price: int = 0

## Price received when selling this item to the merchant.
@export var sell_price: int = 0


func get_buy_price() -> int:
	return buy_price


func get_sell_price() -> int:
	return sell_price
