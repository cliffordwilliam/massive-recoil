extends Node
## Shop overlay for browsing and purchasing items from the merchant.
##
## Populates the item list with all [ItemData] resources available at the current
## chapter and delegates navigation input to [UIShopItemList].

@onready var ui_shop_item_list: UIShopItemList = $UIShopItemList


func _ready() -> void:
	var chapter: int = GameState.chapter
	var buyable: Array[ItemData] = ItemRegistry.get_all_items().filter(
		func(item: ItemData) -> bool: return item.buy_price > 0 and item.availability <= chapter
	)
	ui_shop_item_list.set_buy_items(buyable)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		ui_shop_item_list.next()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		ui_shop_item_list.previous()
		get_viewport().set_input_as_handled()
