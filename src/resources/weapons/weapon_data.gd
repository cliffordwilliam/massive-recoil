class_name WeaponData
extends Resource

# Static definition data (set in inspector)
@export var id: StringName
@export var arms_sprite: SpriteFrames
@export var icon_sprite: Texture2D
@export var description_sprite: Texture2D
@export var buy_page_list_item_scene: PackedScene
@export var inv_page_list_item_scene: PackedScene
@export var price: int
@export var magazine_size: int
@export var reload_speed: float

# Runtime mutable state (not @export — doesn't need to be serialized)
var magazine_current: int = 1
var reserve_ammo: int
var is_owned: bool
var was_bought: bool
