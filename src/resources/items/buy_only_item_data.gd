class_name BuyOnlyItemData
extends ShopItemData
## Item that can only be purchased from the merchant — never sold back.
##
## Used for permanent upgrades such as the field pack expansion.

## Price to purchase this item from the merchant.
@export var buy_price: int = 0


func get_buy_price() -> int:
	return buy_price
