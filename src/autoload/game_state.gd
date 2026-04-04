# GameState autoload
extends Node
## Tracks game-wide progression state.
##
## Holds the current chapter, the player's gold, and the set of shop item IDs the
## player has already seen. All three are persisted to the save file.
##
## The current chapter is used by [code]BuyOverlay[/code] to filter which items appear in the shop.
##
## The seen-item set drives the NEW badge in the shop buy overlay: any item whose id
## is absent from [member _seen_shop_item_ids] is considered unseen and shown as new.

const _DEFAULT_CHAPTER: int = 1
const _DEFAULT_GOLD: int = _MAX_GOLD
const _MAX_GOLD: int = 99999999

var chapter: int = _DEFAULT_CHAPTER

var gold: int = _DEFAULT_GOLD

var _seen_shop_item_ids: Dictionary[StringName, bool] = {}


func is_shop_item_new(id: StringName) -> bool:
	return not _seen_shop_item_ids.has(id)


func mark_shop_item_seen(id: StringName) -> void:
	_seen_shop_item_ids[id] = true


## Adds [param amount] to [member gold].
## Returns the new gold total, or [code]-1[/code] if adding would exceed [constant _MAX_GOLD].
func add_gold(amount: int) -> int:
	if gold + amount > _MAX_GOLD:
		return -1
	gold += amount
	return gold


## Subtracts [param amount] from [member gold].
## Returns the new gold total, or [code]-1[/code] if the player cannot afford [param amount].
func spend_gold(amount: int) -> int:
	if gold < amount:
		return -1
	gold -= amount
	return gold


## Resets all state to defaults for a new game session.
func reset_state() -> void:
	chapter = _DEFAULT_CHAPTER
	gold = _DEFAULT_GOLD
	_seen_shop_item_ids.clear()


## Returns state serialized for saving.
func get_save_data() -> Dictionary[String, Variant]:
	# See: "res://docs/godot/how_to_save_stringname.md"
	return {
		"chapter": chapter, "gold": gold, "seen_shop_item_ids": Array(_seen_shop_item_ids.keys())
	}


## Hydrates state from [param save_data].
func load_save(save_data: Dictionary[String, Variant]) -> void:
	chapter = int(save_data.get("chapter", _DEFAULT_CHAPTER))
	gold = int(save_data.get("gold", _DEFAULT_GOLD))

	_seen_shop_item_ids.clear()
	var raw_seen: Variant = save_data.get("seen_shop_item_ids", [])
	if raw_seen is Array:
		for entry: Variant in raw_seen as Array:
			if entry is String and not (entry as String).is_empty():
				_seen_shop_item_ids[StringName(entry as String)] = true
