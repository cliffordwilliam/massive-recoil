class_name BuyOverlay
extends BaseOverlay
## Shop overlay for browsing and purchasing items from the shop.
##
## Populates the item list with all [ItemData] resources available at the current
## chapter. [code]up[/code] / [code]down[/code] navigate the list; [code]accept[/code]
## purchases the selected item.
##
## See: "res://docs/decisions/overlay_router.md"

@onready var _ui_shop_item_list: UIShopItemList = $UIShopItemList


func _on_close() -> void:
	pass


func _hydrate_ui() -> void:
	var chapter: int = GameState.chapter
	var buyable: Array[ItemData] = ItemRegistry.get_all_items().filter(
		# buy_price > 0 guard is intentionally absent — AVAILABILITY_NOT_FOR_SALE exceeds
		# MAX_CHAPTER, so non-shop items never pass this filter. The chapter check is
		# self-enforcing. See: "res://docs/decisions/item_architecture.md"
		func(item: ItemData) -> bool: return item.availability <= chapter
	)
	_ui_shop_item_list.set_buy_items(buyable)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("down"):
		_ui_shop_item_list.next()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("up"):
		_ui_shop_item_list.previous()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("accept"):
		_try_buy()
		get_viewport().set_input_as_handled()


## Attempts to purchase the currently selected item.
## Places the item via [PlayerInventory], then deducts gold from [GameState].
## Prints the outcome — no UI feedback yet.
func _try_buy() -> void:
	var item_data: ItemData = _ui_shop_item_list.get_selected_buy_item()
	if item_data == null:
		print("BuyOverlay: no item selected")
		return

	if GameState.gold < item_data.buy_price:
		print(
			(
				"BuyOverlay: not enough gold to buy '%s' (need %d, have %d)"
				% [item_data.ui_name, item_data.buy_price, GameState.gold]
			)
		)
		return

	var pos: Vector2i = PlayerInventory.find_open_position(item_data)
	if pos == Vector2i(-1, -1):
		print("BuyOverlay: no inventory space for '%s'" % item_data.ui_name)
		return

	var placed: bool = PlayerInventory.place_item(item_data.id, pos)
	(
		Utils
		. require(
			placed,
			(
				"BuyOverlay._try_buy: expected place_item to succeed for '%s' at %s"
				% [
					item_data.ui_name,
					pos,
				]
			)
		)
	)
	GameState.gold -= item_data.buy_price

	# Refresh the shop list so NEW badges / availability reflect the updated
	# inventory and GameState.
	_hydrate_ui()

	print(
		(
			"BuyOverlay: bought '%s' for %d gold (remaining: %d)"
			% [item_data.ui_name, item_data.buy_price, GameState.gold]
		)
	)
