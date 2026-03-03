class_name WeaponData
extends Resource

# Static definition data (set in inspector, authored in the .tres file, never mutated at runtime)
@export var id: StringName
@export var arms_sprite: SpriteFrames
@export var icon_sprite: Texture2D
@export var description_sprite: Texture2D
@export var buy_page_list_item_scene: PackedScene
@export var inv_page_list_item_scene: PackedScene
@export var price: int
@export var magazine_size: int
@export var reload_speed: float

# Runtime state — not @export so ResourceSaver never touches the .tres file.
# Lifecycle: hydrated from the save file when a slot loads → mutated freely during play
# → dumped back to the save file when the player saves.
# All mutation must go through GameState methods, never directly.
var magazine_current: int = 1
var reserve_ammo: int
var is_owned: bool
var was_bought: bool
