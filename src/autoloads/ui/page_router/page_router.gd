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
@onready var upgrade_page: UpgradePage = $UpgradePage
@onready var handgun_upgrade_page: HandgunUpgradePage = $HandgunUpgradePage
@onready var rifle_upgrade_page: RifleUpgradePage = $RifleUpgradePage


func _ready() -> void:
	# Staying visible in the editor is distracting, so I only show myself at runtime.
	show()

	# PROCESS_MODE_ALWAYS is intentional — not PROCESS_MODE_WHEN_PAUSED.
	# The player can press "inventory" during live gameplay (game not yet paused),
	# so this node must process input before any pause is set. Switching to
	# PROCESS_MODE_WHEN_PAUSED would silently drop that initial keypress.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Turn all of my BasePage children off.
	for child in get_children():
		if child is BasePage:
			child.is_active = false


func open_shop_page() -> bool:
	return _open_page(shop_page)


func open_buy_page() -> bool:
	return _open_page(buy_page)


func open_upgrade_page() -> bool:
	return _open_page(upgrade_page)


func open_handgun_upgrade_page() -> bool:
	return _open_page(handgun_upgrade_page)


func open_rifle_upgrade_page() -> bool:
	return _open_page(rifle_upgrade_page)


func close_page() -> bool:
	if current_page:
		current_page.is_active = false
		current_page = null
		get_tree().paused = false
		page_closed.emit()
		return true
	return false


func _unhandled_key_input(event: InputEvent) -> void:
	# _unhandled_key_input only fires for InputEventKey — no guard needed.
	# Doc ref: docs/godot/classes/class_node.rst — _unhandled_key_input()
	# This game uses keyboard input only.

	# Close the currently opened BasePage.
	if event.is_action_pressed("cancel") and current_page:
		close_page()
		get_viewport().set_input_as_handled()

	# Open inventory page.
	elif event.is_action_pressed("inventory") and not current_page:
		_open_inventory_page()
		get_viewport().set_input_as_handled()


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
