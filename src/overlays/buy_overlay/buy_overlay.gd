class_name BuyOverlay
extends BaseOverlay
## Shop overlay for browsing and purchasing items from the shop.
##
## Populates the item list with all [ItemData] resources available at the current
## chapter. [code]up[/code] / [code]down[/code] navigate the list; [code]accept[/code]
## purchases the selected item.

@onready var _ui_shop_item_list: UIShopItemList = $UIShopItemList


func _on_close() -> void:
	pass


func _on_open() -> void:
	var chapter: int = GameState.chapter
	var buyable: Array[ItemData] = ItemRegistry.get_all_items().filter(
		func(item: ItemData) -> bool: return item.buyable and item.availability <= chapter
	)
	_ui_shop_item_list.set_buy_items(buyable)


func _unhandled_key_input(event: InputEvent) -> void:
	var dir: int = Utils.get_axis(event, InputActions.UP, InputActions.DOWN)
	if dir != 0:
		if dir > 0:
			_ui_shop_item_list.next()
		else:
			_ui_shop_item_list.previous()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(InputActions.ACCEPT):
		_try_buy()
		get_viewport().set_input_as_handled()


func _try_buy() -> void:
	var item_data: ItemData = _ui_shop_item_list.get_selected_buy_item()
	if item_data == null or GameState.gold < item_data.buy_price:
		return
	if not PlayerInventory.create_batch(item_data.id, 1):
		return
	GameState.spend_gold(item_data.buy_price)
	_on_open()
