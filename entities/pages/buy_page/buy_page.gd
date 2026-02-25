class_name ShopPage
extends Sprite2D

@onready var scroll_list: ScrollList = $ScrollList
@onready var thumbnail: Sprite2D = $Thumbnail
@onready var money: NumberDisplay = $Money


func _ready() -> void:
	_refresh()
	scroll_list.item_selected.connect(_on_item_selected)
	scroll_list.index_changed.connect(_on_index_changed)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cancel"):
		get_tree().current_scene.page_router.close_page()


func _refresh() -> void:
	money.display_number(GameState.money)
	scroll_list.items.get_children().map(func(c: BuyPageListItem) -> void: c.free())
	for id: StringName in GameState.weapons:
		if id == "arms":
			continue
		var w: Dictionary = GameState.weapons[id]
		var item: BuyPageListItem = w["buy_page_list_item_scene"].instantiate()
		item.name = id
		item.set_tag(not w["was_bought"], w["is_owned"])
		scroll_list.items.add_child(item)
	scroll_list.refresh()


func _on_index_changed(id: StringName) -> void:
	thumbnail.texture = GameState.weapons[id]["thumbnail_sprite"]


func _on_item_selected(id: StringName) -> void:
	if GameState.money >= GameState.weapons[id]["price"] and not GameState.weapons[id]["is_owned"]:
		GameState.money -= GameState.weapons[id]["price"]
		GameState.weapons[id]["was_bought"] = true
		GameState.weapons[id]["is_owned"] = true
		_refresh()
