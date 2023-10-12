class_name InventoryItem extends Node2D

onready var inventory = load("res://inventory/Inventory.tscn")

const ITEM_SPRITE_MARGIN = Vector2(10, 10)
var item: Item
var pos: Vector2
var dimension: Vector2 setget , _get_dimension
var rotated: bool setget _set_rotated

func _ready():
	_set_rotated(rotated)
	pass

func _init(item: Item, pos: Vector2, rotated: bool):
	self.item = item
	self.pos = pos
	self.rotated = rotated
	pass

func _get_dimension():
	if(!rotated):
		return item.dimension
	return Vector2(item.dimension.y, item.dimension.x)
	
func _set_rotated(is_rotated: bool):
	var slot_size_vector = Vector2(Shared.SLOT_SIZE*2, Shared.SLOT_SIZE*2)
	var size = (slot_size_vector - ITEM_SPRITE_MARGIN) * _get_dimension()
	var offset = -0.5 * ITEM_SPRITE_MARGIN * _get_dimension()
	item._get_item_texture()._set_min_size(Vector2(size.x if !is_rotated else size.y, size.x if is_rotated else size.y))
	item._set_rect_position(Vector2(offset.x if !is_rotated else offset.y, offset.x if is_rotated else offset.y))
#1, 1 => 30, 30 => -5, -5
#2, 2 => 60, 60 => -10. -10
func _get_item():
	return item
