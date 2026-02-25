extends Sprite2D

@onready var scroll_list: ScrollList = $ScrollList


func _ready() -> void:
	for id: StringName in GameState.weapons:
		if id == "arms":
			continue
		var w: Dictionary = GameState.weapons[id]
		if w["is_owned"]:
			var item: InventoryPageListItem = w["inv_page_list_item_scene"].instantiate()
			item.name = id
			scroll_list.items.add_child(item)
	scroll_list.refresh()
	scroll_list.item_selected.connect(_on_item_selected)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		get_tree().current_scene.page_router.close_page()


func _on_item_selected(id: StringName) -> void:
	GameState.equip(id)
