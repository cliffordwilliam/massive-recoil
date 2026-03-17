# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the GameState autoload
extends Node
## Tracks game-wide progression state.
##
## Holds the current chapter and the set of shop item IDs the player has already
## seen. Both are persisted to the save file.
##
## The current chapter is used by [code]buy_overlay.gd[/code] to
## filter which items appear in the shop.
##
## The seen-item set drives the NEW badge in the shop buy page: any item whose id
## is absent from [member _seen_shop_item_ids] is considered unseen and shown as new.

## Starting chapter used on a new game and as the fallback when save data is invalid.
const DEFAULT_CHAPTER: int = 1

## Current chapter. Controls which items are available in the shop.
var chapter: int = DEFAULT_CHAPTER:
	set(value):
		# Wrong chapter silently corrupts all shop availability filtering — crash is intentional.
		Utils.require(
			_is_valid_chapter(value),
			(
				"GameState.chapter: value %d out of range [%d, %d]"
				% [value, ItemSchema.MIN_CHAPTER, ItemSchema.MAX_CHAPTER]
			)
		)
		# Godot 4 GDScript detects self-assignment within a setter and writes
		# directly to the backing store — this does NOT cause infinite recursion.
		chapter = value

## IDs of items the player has already seen in the shop buy page.
## Used as a set — values are always [code]true[/code] and carry no meaning.
var _seen_shop_item_ids: Dictionary[StringName, bool] = {}


## Returns [code]true[/code] if the player has not yet seen [param id] in the shop.
func is_shop_item_new(id: StringName) -> bool:
	return not _seen_shop_item_ids.has(id)


## Marks [param id] as seen, clearing its NEW badge in the shop.
func mark_shop_item_seen(id: StringName) -> void:
	_seen_shop_item_ids[id] = true


## Hydrates state from [param save_data].
##
## The load is not atomic — [member chapter] is assigned before [member _seen_shop_item_ids]
## is validated. This is intentional: [method Utils.require] crashes immediately, so
## partially-updated state is never observable. Rollback would add complexity with no benefit.
func load_save(save_data: Dictionary) -> void:
	chapter = _parse_chapter(save_data)
	_parse_seen_ids(save_data)


## Validates and returns the chapter value from [param save_data].
## Crashes on missing or out-of-range value.
func _parse_chapter(save_data: Dictionary) -> int:
	var raw_chapter: Variant = save_data.get("chapter", DEFAULT_CHAPTER)
	var parsed_chapter: Variant = Utils.parse_json_int(raw_chapter)
	Utils.require(parsed_chapter != null, "GameState.load_save: invalid chapter '%s'" % raw_chapter)
	var chapter_int: int = parsed_chapter as int
	Utils.require(
		_is_valid_chapter(chapter_int),
		(
			"GameState.load_save: chapter %d out of range [%d, %d]"
			% [chapter_int, ItemSchema.MIN_CHAPTER, ItemSchema.MAX_CHAPTER]
		)
	)
	return chapter_int


## Validates and populates [member _seen_shop_item_ids] from [param save_data].
## Crashes on any invalid, unknown, or duplicate entry.
func _parse_seen_ids(save_data: Dictionary) -> void:
	var raw_seen: Variant = save_data.get("seen_shop_item_ids", [])
	_seen_shop_item_ids.clear()
	Utils.require(
		raw_seen is Array,
		"GameState.load_save: seen_shop_item_ids is not an Array — '%s'" % raw_seen
	)
	for raw_id: Variant in raw_seen as Array:
		Utils.require(
			raw_id is String, "GameState.load_save: non-String entry in seen_shop_item_ids"
		)
		Utils.require(
			not (raw_id as String).is_empty(),
			"GameState.load_save: empty string entry in seen_shop_item_ids"
		)
		var seen_id: StringName = StringName(raw_id as String)
		# Crash on unknown IDs — save data is all-or-nothing. Silently skipping stale
		# IDs would mask corruption. If an item is removed, update or wipe the save.
		ItemRegistry.validate_item_id(seen_id)
		Utils.require(
			not _seen_shop_item_ids.has(seen_id),
			"GameState.load_save: duplicate id '%s' in seen_shop_item_ids" % seen_id
		)
		_seen_shop_item_ids[seen_id] = true


## Returns [code]true[/code] if [param value] is within the valid chapter range.
## Shared by the [member chapter] setter and [method load_save] to keep the bounds in one place.
func _is_valid_chapter(value: int) -> bool:
	return value >= ItemSchema.MIN_CHAPTER and value <= ItemSchema.MAX_CHAPTER


## Returns state serialized for saving.
func get_save_data() -> Dictionary:
	return {
		"chapter": chapter,
		"seen_shop_item_ids":
		_seen_shop_item_ids.keys().map(func(k: StringName) -> String: return str(k)),
	}
