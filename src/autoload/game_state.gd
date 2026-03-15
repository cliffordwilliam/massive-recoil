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
func load_save(save_data: Dictionary) -> void:
	var raw_chapter: Variant = save_data.get("chapter", DEFAULT_CHAPTER)
	var chapter_int: int = DEFAULT_CHAPTER
	var parsed_chapter: Variant = Utils.parse_json_int(raw_chapter)
	if parsed_chapter != null:
		chapter_int = parsed_chapter
	else:
		push_warning(
			(
				"GameState.load_save: invalid chapter '%s', defaulting to %d"
				% [raw_chapter, DEFAULT_CHAPTER]
			)
		)
	# Cannot delegate range validation to the setter here: the setter calls
	# Utils.require on any out-of-range value — correct for programmer errors,
	# but save data can be corrupt through no fault of the program. Calling
	# _is_valid_chapter first and falling back to DEFAULT_CHAPTER lets load_save
	# recover gracefully without crashing.
	if _is_valid_chapter(chapter_int):
		chapter = chapter_int
	else:
		push_warning(
			(
				"GameState.load_save: chapter %d out of range, defaulting to %d"
				% [chapter_int, DEFAULT_CHAPTER]
			)
		)
		chapter = DEFAULT_CHAPTER

	var raw_seen: Variant = save_data.get("seen_shop_item_ids", [])
	# Always clear before parsing — even if the value is malformed — so stale
	# seen IDs from a previous session never bleed into the loaded state.
	_seen_shop_item_ids.clear()
	if not raw_seen is Array:
		push_warning("GameState.load_save: invalid seen_shop_item_ids '%s', skipping" % [raw_seen])
	else:
		for raw_id: Variant in raw_seen as Array:
			# Soft skip for structural garbage: a non-String or empty entry can
			# appear in corrupt or hand-edited save files. Log and skip — there
			# is nothing to recover. This contrasts intentionally with the hard
			# crash below for unknown IDs: those are structurally valid strings
			# that no longer match any item, meaning game data changed with no
			# recovery path (renamed or deleted item).
			if not raw_id is String:
				push_warning("GameState.load_save: skipping non-String entry in seen_shop_item_ids")
				continue
			if (raw_id as String).is_empty():
				push_warning(
					"GameState.load_save: skipping empty string entry in seen_shop_item_ids"
				)
				continue
			var seen_id: StringName = StringName(raw_id as String)
			# Intentional by design: unknown IDs crash the game (OS.crash, both debug
			# and release). A mismatch here means an item was renamed or deleted during
			# development, or the player manually edited the save file — neither case
			# has a sensible recovery path. Silently accumulating orphaned IDs would
			# leave the seen-set in an inconsistent state with no visible symptom.
			# This is not a bug or an oversight.
			#
			# validate_item_id is used instead of get_item with a discarded return value.
			# Both crash on an unknown id, but validate_item_id makes the intent explicit:
			# the goal here is validation only, not retrieval.
			ItemRegistry.validate_item_id(seen_id)
			_seen_shop_item_ids[seen_id] = true


## Returns [code]true[/code] if [param value] is within the valid chapter range.
##
## Extracted so the bounds expression lives in exactly one place. The
## [member chapter] setter wraps this in [method Utils.require] (crash on
## programmer error); [method load_save] uses it as a soft guard and falls
## back to [constant DEFAULT_CHAPTER] on corrupt save data. Without this
## helper, both sites would duplicate the same [code]>= MIN and <= MAX[/code]
## expression and could drift independently if the logic ever changes.
func _is_valid_chapter(value: int) -> bool:
	return value >= ItemSchema.MIN_CHAPTER and value <= ItemSchema.MAX_CHAPTER


## Returns state serialized for saving.
func get_save_data() -> Dictionary:
	return {
		"chapter": chapter,
		"seen_shop_item_ids":
		_seen_shop_item_ids.keys().map(func(k: StringName) -> String: return str(k)),
	}
