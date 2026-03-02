class_name PageRouter
extends CanvasLayer

signal page_closed

const SHOP_PAGE = preload("uid://euoup28876nb")
const INVENTORY_PAGE = preload("uid://cenchx8ug57g2")


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	if Input.is_action_just_pressed("cancel") and get_child_count():
		close_page()
	elif Input.is_action_just_pressed("inventory") and not get_child_count():
		open_page(INVENTORY_PAGE)


func open_shop_page() -> void:
	open_page(SHOP_PAGE)


func open_page(new_page: PackedScene) -> void:
	if not get_child_count():
		add_child(new_page.instantiate())
		get_tree().paused = true


func close_page() -> void:
	for old_page in get_children():
		remove_child(old_page)
		old_page.queue_free()
	get_tree().paused = false
	page_closed.emit()
