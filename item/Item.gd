class_name Item extends Node2D

var dimension : Vector2
var texture: ItemTexture setget , _get_item_texture

func _init(dimension: Vector2, texturePath: String = ""):
	self.dimension = dimension
	self.texture = ItemTexture.new(texturePath)
	self.z_index = 5
	self.add_child(self.texture)
	pass

func _get_item_texture():
	return texture

func _set_rect_position(pos: Vector2):
	texture.rect_position = pos
