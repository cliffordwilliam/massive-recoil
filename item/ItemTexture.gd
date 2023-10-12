class_name ItemTexture extends TextureRect

func _ready():
	pass

func _init(texturePath: String = ""):
	texture = load(texturePath)
	modulate.a = 1
	expand = true

func _set_min_size(pos: Vector2):
	rect_min_size = pos
