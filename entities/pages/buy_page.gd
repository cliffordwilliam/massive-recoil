class_name ShopPage
extends Sprite2D

@onready var scroll_list: ScrollList = $ScrollList
@onready var thumbnail: Sprite2D = $Thumbnail
@onready var number_display: NumberDisplay = $NumberDisplay


func _ready() -> void:
	number_display.display_number(GameState.money)
	for weapon_name: String in GameState.weapons:
		var w: Dictionary = GameState.weapons[weapon_name]
		if w["location"] == "shop":
			var item: Sprite2D = w["buy_page_list_item_scene"].instantiate()
			item.name = weapon_name
			scroll_list.items.add_child(item)
	scroll_list.refresh()
	scroll_list.item_selected.connect(_on_item_selected)
	scroll_list.index_changed.connect(_on_index_changed)
	_on_index_changed(scroll_list.items.get_child(0).name, 0)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("accept"):
		get_tree().current_scene.page_router.close_page()


func _on_index_changed(id: String, _index: int) -> void:
	thumbnail.texture = GameState.weapons[id]["thumbnail_sprite"]


func _on_item_selected(id: String, index: int) -> void:
	print(id, index)
