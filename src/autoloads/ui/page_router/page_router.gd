# Autoload carousel that shows one BasePage at a time and pauses the game while open.
# The only system that can pause gameplay. BasePage overlays are distinct from non‑gameplay
# scenes (main menu, splash, load screen). BaseRoom is the only gameplay current scene.
extends CanvasLayer

signal page_closed

var current_page: BasePage = null

# My list of BasePage instances goes here.
# These cannot be null, I add them via scene tree GUI, game will not even run if its not valid.
@onready var inventory_page: InventoryPage = $InventoryPage
@onready var buy_page: BuyPage = $BuyPage
@onready var shop_page: ShopPage = $ShopPage


func _ready() -> void:
	# Staying visible in the editor is distracting, so I only show myself at runtime.
	show()

	# Me and my BasePage children always run no matter what, even during pause.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Turn all of my BasePage children off.
	for child in get_children():
		if child is BasePage:
			child.is_active = false


func _unhandled_input(event: InputEvent) -> void:
	# This game uses keyboard input only.
	if event is not InputEventKey:
		return

	# Close the currently opened BasePage.
	if event.is_action_pressed("cancel") and current_page:
		close_page()
		get_viewport().set_input_as_handled()

	# Open inventory page.
	elif event.is_action_pressed("inventory") and not current_page:
		_open_inventory_page()
		get_viewport().set_input_as_handled()


func open_shop_page() -> bool:
	return _open_page(shop_page)


func open_buy_page() -> bool:
	return _open_page(buy_page)


func close_page() -> bool:
	if current_page:
		current_page.is_active = false
		current_page = null
		get_tree().paused = false
		page_closed.emit()
		return true
	return false


func _open_inventory_page() -> bool:
	return _open_page(inventory_page)


func _open_page(new_page: BasePage) -> bool:
	if not Utils.require(new_page is BasePage, "PageRouter: _open_page can only receive BasePage"):
		return false

	close_page() # To handle when a page request another page to open.

	if not current_page:
		current_page = new_page
		current_page.is_active = true
		get_tree().paused = true
		return true
	return false
