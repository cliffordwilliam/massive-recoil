# Shows all four shop options. Player can browse and pick "Sell", "Buy", "Upgrade" or "Cancel".
# TODO: If there are new item in buy/upgrade page, then new tag shows up on "Buy"/"Upgrade" button.
class_name ShopPage
extends BasePage

const SHOP_PAGE_SELL_LIST_ITEM = preload("uid://drw00i6h4i0p4")
const SHOP_PAGE_BUY_LIST_ITEM = preload("uid://dhu3qh1e0k7ud")
const SHOP_PAGE_UPGRADE_LIST_ITEM = preload("uid://c5bmsfwwlmivx")
const SHOP_PAGE_CANCEL_LIST_ITEM = preload("uid://ch55hw3vps262")
const SELL_ID: StringName = &"sell"
const BUY_ID: StringName = &"buy"
const UPGRADE_ID: StringName = &"upgrade"
const CANCEL_ID: StringName = &"cancel"

@onready var scroll_list: ScrollList = $ScrollList


func _hydrate_ui() -> void:
	# TODO: Need a feature to reveal new buy/upgrade item then toggle my buy/upgrade item tags.
	# Shop page will only ever have 4 items here so this approach is fine.
	var scroll_list_items: Array[ListItem] = []

	var sell_item: ListItem = SHOP_PAGE_SELL_LIST_ITEM.instantiate()
	sell_item.set_id(SELL_ID)
	scroll_list_items.append(sell_item)

	var buy_item: ListItem = SHOP_PAGE_BUY_LIST_ITEM.instantiate()
	buy_item.set_id(BUY_ID)
	scroll_list_items.append(buy_item)

	var upgrade_item: ListItem = SHOP_PAGE_UPGRADE_LIST_ITEM.instantiate()
	upgrade_item.set_id(UPGRADE_ID)
	scroll_list_items.append(upgrade_item)

	var cancel_item: ListItem = SHOP_PAGE_CANCEL_LIST_ITEM.instantiate()
	cancel_item.set_id(CANCEL_ID)
	scroll_list_items.append(cancel_item)

	scroll_list.set_items(scroll_list_items)


func _on_scroll_list_item_selected(id: StringName) -> void: # Connected via engine GUI.
	if id == SELL_ID:
		pass # TODO: Make sell page
	elif id == BUY_ID:
		PageRouter.open_buy_page()
	elif id == UPGRADE_ID:
		PageRouter.open_upgrade_page()
	elif id == CANCEL_ID:
		PageRouter.close_page()
