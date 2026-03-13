class_name SellOnlyItemData
extends ShopItemData
## Item that can only be sold to the merchant — never purchased.
##
## Used for ammo, which is found in the world but not sold by the merchant.

## Price received when selling this item to the merchant.
@export var sell_price: int = 0


func get_sell_price() -> int:
	return sell_price
