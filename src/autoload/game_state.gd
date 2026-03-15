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
		# An out-of-range chapter is always a programmer error: load_save performs
		# its own range check before touching this setter, so any invalid value
		# here means a code path supplied a chapter that was never valid.
		# Crashing in both debug and release is intentional — a wrong chapter
		# silently corrupts all shop availability filtering with no other symptom,
		# making a crash far preferable to continuing in a broken state.
		# Delegate to _is_valid_chapter so the bounds expression lives in one place.
		# Both this setter and load_save share the same check; keeping it in a helper
		# prevents the two sites from drifting if the logic ever changes.
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
## [b]INTENTIONAL — DO NOT MARK AS AN ISSUE:[/b] [code]load_save[/code] is not
## atomic — [member chapter] is assigned before [member _seen_shop_item_ids] is
## validated. If a [code]seen_shop_item_ids[/code] entry fails (unknown or duplicate
## ID), [member chapter] has already been updated to its new value. This is
## intentional: [method Utils.require] → [method OS.crash] terminates the process
## immediately, so no partially-updated state is ever observable at runtime.
## Rollback logic would add complexity with no runtime benefit given the fail-hard
## contract. If [method OS.crash] is ever replaced with a recoverable error,
## revisit this and make the load transactional.
func load_save(save_data: Dictionary) -> void:
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
	chapter = chapter_int

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
		# INTENTIONAL DO NOT MARK THIS AS AN ISSUE — crash on unknown seen IDs,
		# do not silently drop them.
		# Save data is treated as all-or-nothing — either every ID in the seen-set
		# is valid or the load is rejected entirely. Silently skipping stale IDs
		# would allow partial loads and make corruption harder to detect.
		# If an item is removed or renamed, update or wipe the save file.
		ItemRegistry.validate_item_id(seen_id)
		Utils.require(
			not _seen_shop_item_ids.has(seen_id),
			"GameState.load_save: duplicate id '%s' in seen_shop_item_ids" % seen_id
		)
		_seen_shop_item_ids[seen_id] = true


## Returns [code]true[/code] if [param value] is within the valid chapter range.
##
## Extracted so the bounds expression lives in exactly one place. Both the
## [member chapter] setter and [method load_save] wrap this in [method Utils.require]
## (crash on invalid). Without this helper, both sites would duplicate the same
## [code]>= MIN and <= MAX[/code] expression and could drift independently.
func _is_valid_chapter(value: int) -> bool:
	return value >= ItemSchema.MIN_CHAPTER and value <= ItemSchema.MAX_CHAPTER


## Returns state serialized for saving.
func get_save_data() -> Dictionary:
	return {
		"chapter": chapter,
		"seen_shop_item_ids":
		_seen_shop_item_ids.keys().map(func(k: StringName) -> String: return str(k)),
	}
