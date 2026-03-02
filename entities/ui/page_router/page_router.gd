class_name PageRouter
extends CanvasLayer

signal page_closed

var current_page: BasePage = null

@onready var inventory_page: InventoryPage = $InventoryPage
@onready var shop_page: BuyPage = $BuyPage


func _ready() -> void:
	visible = true # Editor sets me invisible as it blocks dev view
	process_mode = Node.PROCESS_MODE_ALWAYS # Router and pages under me always run
	for p in get_children(): # Then disable all of my page kids
		if p is BasePage:
			p.set_enabled(false)


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	if Input.is_action_just_pressed("cancel") and current_page:
		close_page()
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed("inventory") and not current_page:
		open_inventory_page()
		get_viewport().set_input_as_handled()


func open_shop_page() -> bool:
	return _show_page(shop_page)


func open_inventory_page() -> bool:
	return _show_page(inventory_page)


func close_page() -> bool:
	if not current_page:
		return false
	current_page.set_enabled(false)
	current_page = null
	get_tree().paused = false
	page_closed.emit()
	return true


func _show_page(new_page: BasePage) -> bool:
	if current_page:
		return false
	current_page = new_page
	current_page.set_enabled(true)
	get_tree().paused = true
	return true
