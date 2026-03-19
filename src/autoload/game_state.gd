# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the GameState autoload
extends Node
## Tracks game-wide progression state.
##
## Holds the current chapter, the player's gold, and the set of shop item IDs the
## player has already seen. All three are persisted to the save file.
##
## The current chapter is used by [code]buy_overlay.gd[/code] to
## filter which items appear in the shop.
##
## The seen-item set drives the NEW badge in the shop buy page: any item whose id
## is absent from [member _seen_shop_item_ids] is considered unseen and shown as new.

## Starting chapter used on a new game.
const _DEFAULT_CHAPTER: int = 1

## Starting gold used on a new game.
const _DEFAULT_GOLD: int = 10000

## Maximum gold the player can hold at once.
const _MAX_GOLD: int = 99999999

## Current chapter. Controls which items are available in the shop.
var chapter: int = _DEFAULT_CHAPTER:
	set(value):
		# Wrong chapter silently corrupts all shop availability filtering — crash is intentional.
		Utils.require(
			value >= ItemSchema.MIN_CHAPTER and value <= ItemSchema.MAX_CHAPTER,
			(
				"GameState.chapter: value %d out of range [%d, %d]"
				% [value, ItemSchema.MIN_CHAPTER, ItemSchema.MAX_CHAPTER]
			)
		)
		# Godot 4 GDScript detects self-assignment within a setter and writes
		# directly to the backing store — this does NOT cause infinite recursion.
		# See: "res://docs/godot/recursion_does_not_happen_in_self_assign_in_its_own_setter.md"
		chapter = value

## Current gold amount. Range: [code]0[/code]–[constant _MAX_GOLD].
var gold: int = _DEFAULT_GOLD:
	set(value):
		Utils.require(
			value >= 0 and value <= _MAX_GOLD,
			"GameState.gold: value %d out of range [0, %d]" % [value, _MAX_GOLD]
		)
		# Godot 4 GDScript detects self-assignment within a setter and writes
		# directly to the backing store — this does NOT cause infinite recursion.
		# See: "res://docs/godot/recursion_does_not_happen_in_self_assign_in_its_own_setter.md"
		gold = value

## IDs of items the player has already seen in the shop buy page.
## Used as a set — values are always [code]true[/code] and carry no meaning.
var _seen_shop_item_ids: Dictionary[StringName, bool] = {}


## Returns [code]true[/code] if the player has not yet seen [param id] in the shop.
func is_shop_item_new(id: StringName) -> bool:
	return not _seen_shop_item_ids.has(id)


## Marks [param id] as seen, clearing its NEW badge in the shop.
func mark_shop_item_seen(id: StringName) -> void:
	_seen_shop_item_ids[id] = true


## Returns state serialized for saving.
func get_save_data() -> Dictionary:
	var ids: Array[String] = []
	for k: StringName in _seen_shop_item_ids:
		ids.append(str(k))

	return {
		"chapter": chapter,
		"gold": gold,
		"seen_shop_item_ids": ids,
	}


## Hydrates state from [param save_data].
##
## The load is not atomic — fields are assigned in order ([member chapter],
## [member gold], then [member _seen_shop_item_ids]). This is intentional: a hard
## crash on corrupt data is preferred over continuing with partial or inconsistent
## state, which is harder to debug. [method Utils.require] crashes immediately on
## the first violation, so partially-updated state is never observable in practice.
## See: "res://docs/decisions/item_architecture.md" (Error handling philosophy).
func load_save(save_data: Dictionary) -> void:
	chapter = _parse_chapter(save_data)
	gold = _parse_gold(save_data)
	_parse_seen_ids(save_data)


## Validates and returns the chapter value from [param save_data].
## Crashes on missing or out-of-range value.
func _parse_chapter(save_data: Dictionary) -> int:
	var raw_chapter: Variant = save_data.get("chapter", null)
	var parsed_chapter: Variant = Utils.parse_json_int(raw_chapter)
	Utils.require(parsed_chapter != null, "GameState.load_save: invalid chapter '%s'" % raw_chapter)

	var chapter_int: int = parsed_chapter as int
	Utils.require(
		chapter_int >= ItemSchema.MIN_CHAPTER and chapter_int <= ItemSchema.MAX_CHAPTER,
		(
			"GameState.load_save: chapter %d out of range [%d, %d]"
			% [chapter_int, ItemSchema.MIN_CHAPTER, ItemSchema.MAX_CHAPTER]
		)
	)

	return chapter_int


## Validates and returns the gold value from [param save_data].
## Crashes on missing or out-of-range value.
func _parse_gold(save_data: Dictionary) -> int:
	var raw_gold: Variant = save_data.get("gold", null)
	var parsed_gold: Variant = Utils.parse_json_int(raw_gold)
	Utils.require(parsed_gold != null, "GameState.load_save: invalid gold '%s'" % raw_gold)

	var gold_int: int = parsed_gold as int
	Utils.require(
		gold_int >= 0 and gold_int <= _MAX_GOLD,
		"GameState.load_save: gold %d out of range [0, %d]" % [gold_int, _MAX_GOLD]
	)

	return gold_int


## Validates and populates [member _seen_shop_item_ids] from [param save_data].
## Crashes on any invalid, unknown, or duplicate entry.
func _parse_seen_ids(save_data: Dictionary) -> void:
	_seen_shop_item_ids.clear()

	var raw_seen: Variant = save_data.get("seen_shop_item_ids", [])
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
