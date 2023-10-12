class_name InventoryItemFactory extends Node

var item_meta
var pos
var rotated

func _init(item_id: String, pos: Vector2, rotated: bool = false):
	item_meta = Shared.item_db.get(item_id)
	self.pos = pos
	self.rotated = rotated
	
func _build():
	var item = Item.new(Vector2(item_meta.width, item_meta.height), item_meta.texture_path)
	return InventoryItem.new(item, pos, rotated)
