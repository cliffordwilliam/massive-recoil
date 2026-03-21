# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the ItemRegistry autoload
extends Node
## Static catalog of all [ItemData] definitions.
##
## Loads items from [ItemDefinitions] at startup and exposes them for lookup.
## Each item is constructed and validated by [ItemDefinitions] before arriving here.
##
## This autoload holds no runtime state — use [code]PlayerInventory[/code] for
## inventory instances and [code]GameState[/code] for progression state.

## Dictionary mapping [StringName] id to [ItemData].
var _items: Dictionary[StringName, ItemData] = {}


func _ready() -> void:
	for data: ItemData in ItemDefinitions.get_all():
		Utils.require(
			not _items.has(data.id), "ItemRegistry: duplicate id '%s' in ItemDefinitions" % data.id
		)

		_items[data.id] = data

	Utils.require(
		not _items.is_empty(), "ItemRegistry: ItemDefinitions.get_all() returned no items"
	)


## Returns all items in the catalog.
##
## Order reflects dictionary insertion order, which matches the order of entries
## in [ItemDefinitions]. No caller in this project requires a specific display
## order, so no explicit sort is applied.
func get_all_items() -> Array[ItemData]:
	# assign() converts the untyped Array into a typed Array[T].
	# read "res://docs/godot/how_assign_works.md"
	var result: Array[ItemData] = []
	result.assign(_items.values())
	return result


## Returns the [ItemData] for the given [param id].
##
## A missing id is an unrecoverable programmer error — callers should only
## request ids known to exist in the item database. Crashes via [method OS.crash]
## on an unknown id. Never silently returns [code]null[/code].
func get_item_or_crash(id: StringName) -> ItemData:
	Utils.require(_items.has(id), "ItemRegistry.get_item_or_crash: unknown id '%s'" % id)

	return _items[id]


## Asserts that [param id] exists in the catalog.
##
## Crashes via [method OS.crash] if the id is unknown. Use this when the caller
## only needs to confirm an id is valid without needing the [ItemData] return value.
func validate_item_id_or_crash(id: StringName) -> void:
	Utils.require(_items.has(id), "ItemRegistry.validate_item_id_or_crash: unknown id '%s'" % id)
