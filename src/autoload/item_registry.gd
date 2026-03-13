# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the ItemRegistry autoload
extends Node
## Global registry of all shop item definitions.
##
## Loads every [ItemData] resource from the generated items directory at
## startup and stores them in a dictionary keyed by [member ItemData.id].
##
## Generated resources are produced by running
## [code]src/editor/generate_item_resources.gd[/code] from the editor whenever
## [code]src/resources/data/items.json[/code] changes.
##
## Call [method get_item] anywhere in the game to retrieve a definition by id.

const _ITEMS_DIR: String = "res://src/resources/data/generated/items/"

## Dictionary mapping [StringName] id to [ItemData] resource.
var _items: Dictionary = {}


func _ready() -> void:
	var dir: DirAccess = DirAccess.open(_ITEMS_DIR)
	if not Utils.require(
		dir != null,
		"ItemRegistry: items directory not found. Run generate_item_resources.gd first."
	):
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			_load_item(_ITEMS_DIR + file_name)
		file_name = dir.get_next()


## Returns the [ItemData] for the given [param id].
##
## A missing id indicates a logic error — callers should only request ids that
## are known to exist in the item database.
##
## Returns [code]null[/code] if the id is not found.
func get_item(id: StringName) -> ItemData:
	var item: ItemData = _items.get(id, null) as ItemData
	Utils.require(item != null, "ItemRegistry.get_item: unknown id '%s'" % id)
	return item


## Loads a single [ItemData] resource from [param path] and registers it.
func _load_item(path: String) -> void:
	var item: ItemData = load(path) as ItemData
	if not Utils.require(
		item != null, "ItemRegistry: file at '%s' is not a ItemData resource." % path
	):
		return
	_items[item.id] = item
