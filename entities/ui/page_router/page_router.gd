# This is a carousel slide container that can only show one BasePage at a time
# There are no other BasePage manager, this is the only thing in the game that can pause game
class_name PageRouter
extends CanvasLayer

signal page_closed

var current_page: BasePage = null

# My list of BasePage goes here
@onready var inventory_page: InventoryPage = $InventoryPage
@onready var buy_page: BuyPage = $BuyPage


func _ready() -> void:
	# Staying visible in editor is distracting, so I only show myself in runtime
	show()

	# Me and my BasePage children always run no matter what even during pause
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Turn all of my BasePage children off
	for child in get_children():
		if child is BasePage:
			child.is_active = false


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	# Close that one opened BasePage
	if Input.is_action_just_pressed("cancel") and current_page:
		_close_page()
		get_viewport().set_input_as_handled()

	# Open inventory page
	elif Input.is_action_just_pressed("inventory") and not current_page:
		_open_inventory_page()
		get_viewport().set_input_as_handled()


func open_buy_page() -> bool:
	return _open_page(buy_page)


func _open_inventory_page() -> bool:
	return _open_page(inventory_page)


func _close_page() -> bool:
	if current_page:
		current_page.is_active = false
		current_page = null
		get_tree().paused = false
		page_closed.emit()
		return true
	return false


func _open_page(new_page: BasePage) -> bool:
	assert(new_page is BasePage, "PageRouter: _open_page can only receive BasePage")

	if not current_page:
		current_page = new_page
		current_page.is_active = true
		get_tree().paused = true
		return true
	return false
