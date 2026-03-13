extends Node

@onready var ui_shop_item_list: UIShopItemList = $UIShopItemList


func _ready() -> void:
	ui_shop_item_list.set_items(ItemRegistry.get_buyable_shop_states())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		ui_shop_item_list.next()
	elif event.is_action_pressed("ui_up"):
		ui_shop_item_list.previous()
