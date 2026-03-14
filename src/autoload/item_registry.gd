# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the ItemRegistry autoload
extends Node
## Global registry of all item definitions and their runtime state.
##
## The registry is the single source of truth for both static blueprints and
## mutable gameplay state. All items share a single dictionary:
##
## - [member _item_states] — all items across every type
##
## Each entry maps a [StringName] id to an [ItemState] instance,
## which itself holds a pointer back to the immutable [ItemData] blueprint.
##
## On save load, call [method load_save] to hydrate all state from disk
## without rebuilding the registry.
##
## Blueprints are generated [code].tres[/code] files produced by running
## [code]src/editor/generate_item_resources.gd[/code] whenever
## [code]src/resources/data/items.json[/code] changes.

## This is not a node it is just a script, so we cannot export this
const _ITEMS_DIR: String = "res://src/resources/data/generated/items/"

## Dictionary mapping [StringName] id to [ItemState].
var _item_states: Dictionary[StringName, ItemState] = {}


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


## Returns all states whose item has a buy price.
##
## Used to populate the buy page of the shop UI.
## Results are sorted by [member ItemData.availability] ascending, then by
## [member ItemData.id] for a stable, platform-independent order.
func get_buyable_shop_states() -> Array[ItemState]:
	var result: Array[ItemState] = []
	for state: ItemState in _item_states.values():
		if state.data.buy_price > 0:
			result.append(state)
	result.sort_custom(
		func(a: ItemState, b: ItemState) -> bool:
			if a.data.availability != b.data.availability:
				return a.data.availability < b.data.availability
			return a.data.id < b.data.id
	)
	return result


## Returns the [ItemState] for the given [param id].
##
## A missing id indicates a logic error — callers should only request ids
## that are known to exist in the item database.
##
## Returns [code]null[/code] if the id is not found.
func get_item_state(id: StringName) -> ItemState:
	var state: ItemState = _item_states.get(id, null)
	Utils.require(state != null, "ItemRegistry.get_item_state: unknown id '%s'" % id)
	return state


## Hydrates runtime state from a save file dictionary.
##
## [param save_data] should map item id strings to a dictionary of state
## fields, e.g. [code]{ "field_medkit": { "count": 3, "is_new": false } }[/code].
##
## Unknown ids in [param save_data] are silently ignored so that saves from
## older builds remain compatible after items are removed.
func load_save(save_data: Dictionary) -> void:
	for id: String in save_data:
		var state: ItemState = _item_states.get(id, null)
		if state == null:
			continue
		var entry: Dictionary = save_data[id]
		state.count = entry.get("count", 0)
		state.is_new = entry.get("is_new", false)


## Loads a single [ItemData] resource from [param path] and registers
## an [ItemState] for it.
func _load_item(path: String) -> void:
	var data: ItemData = load(path) as ItemData
	if not Utils.require(
		data != null, "ItemRegistry: file at '%s' is not an ItemData resource." % path
	):
		return
	_item_states[data.id] = ItemState.new(data)
