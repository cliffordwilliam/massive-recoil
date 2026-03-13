# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the ItemRegistry autoload
extends Node
## Global registry of all item definitions and their runtime state.
##
## The registry is the single source of truth for both static blueprints and
## mutable gameplay state. Each item type has its own typed dictionary:
##
## - [member _shop_states] — consumables and gear sold at the merchant
##
## Future dictionaries (weapons, treasures, keys) follow the same pattern.
## Each dictionary maps a [StringName] id to its corresponding state object,
## which itself holds a pointer back to the immutable [Resource] blueprint.
##
## On save load, call [method load_save] to hydrate all state from disk
## without rebuilding the registry.
##
## Blueprints are generated [code].tres[/code] files produced by running
## [code]src/editor/generate_item_resources.gd[/code] whenever the source
## JSON files under [code]src/resources/data/[/code] change.

## This is not a node it is just a script, so we cannot export this
const _ITEMS_DIR: String = "res://src/resources/data/generated/items/"

## Dictionary mapping [StringName] id to [ShopItemState].
var _shop_states: Dictionary[StringName, ShopItemState] = {}


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
func get_buyable_shop_states() -> Array[ShopItemState]:
	var result: Array[ShopItemState] = []
	for state: ShopItemState in _shop_states.values():
		if state.data.get_buy_price() > 0:
			result.append(state)
	return result


## Returns the [ShopItemState] for the given [param id].
##
## A missing id indicates a logic error — callers should only request ids
## that are known to exist in the item database.
##
## Returns [code]null[/code] if the id is not found.
func get_item_state(id: StringName) -> ShopItemState:
	var state: ShopItemState = _shop_states.get(id, null)
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
		var state: ShopItemState = _shop_states.get(id, null)
		if state == null:
			continue
		var entry: Dictionary = save_data[id]
		state.count = entry.get("count", 0)
		state.is_new = entry.get("is_new", false)
		state.sold_out = entry.get("sold_out", false)


## Loads a single [ShopItemData] resource from [param path] and registers
## a [ShopItemState] for it.
func _load_item(path: String) -> void:
	var data: ShopItemData = load(path) as ShopItemData
	if not Utils.require(
		data != null, "ItemRegistry: file at '%s' is not a ShopItemData resource." % path
	):
		return
	_shop_states[data.id] = ShopItemState.new(data)
