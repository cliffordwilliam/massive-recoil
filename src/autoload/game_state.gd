# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the GameState autoload
extends Node
## Tracks game-wide progression state.
##
## Holds the current chapter, the player's gold, and the set of shop item IDs the
## player has already seen. All three are persisted to the save file.
##
## The current chapter is used by [code]BuyOverlay[/code] to
## filter which items appear in the shop.
##
## The seen-item set drives the NEW badge in the shop buy overlay: any item whose id
## is absent from [member _seen_shop_item_ids] is considered unseen and shown as new.

## Starting chapter used on a new game.
const _DEFAULT_CHAPTER: int = 1

## Starting gold used on a new game.
const _DEFAULT_GOLD: int = 0

## Maximum gold the player can hold at once.
const _MAX_GOLD: int = 99999999

## Minimum gold the player can hold at once.
const _MIN_GOLD: int = 0

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

## Current gold amount. Used in game to buy items from the shop.
var gold: int = _DEFAULT_GOLD:
	set(value):
		Utils.require(
			value >= _MIN_GOLD and value <= _MAX_GOLD,
			"GameState.gold: value %d out of range [%d, %d]" % [value, _MIN_GOLD, _MAX_GOLD]
		)
		# Godot 4 GDScript detects self-assignment within a setter and writes
		# directly to the backing store — this does NOT cause infinite recursion.
		# See: "res://docs/godot/recursion_does_not_happen_in_self_assign_in_its_own_setter.md"
		gold = value

## IDs of items the player has already seen in the shop buy overlay.
## Used as a set — values are always [code]true[/code] and carry no meaning.
## GDScript has no native Set type; [Dictionary] with constant values is the idiomatic substitute.
## See: "res://docs/decisions/item_architecture.md" (Shop "new item" tag)
var _seen_shop_item_ids: Dictionary[StringName, bool] = {}


## Returns [code]true[/code] if the player has not yet seen [param id] in the shop.
## Crashes if [param id] is unknown or not a buyable item ([code]buy_price == 0[/code]).
func is_shop_item_new(id: StringName) -> bool:
	var item: ItemData = ItemRegistry.get_item_or_crash(id)
	Utils.require(item.is_buyable(), "GameState.is_shop_item_new: item '%s' is not buyable" % id)
	return not _seen_shop_item_ids.has(id)


## Marks [param id] as seen, clearing its NEW badge in the shop.
## Crashes if [param id] is unknown or not a buyable item ([code]buy_price == 0[/code]).
func mark_shop_item_seen(id: StringName) -> void:
	var item: ItemData = ItemRegistry.get_item_or_crash(id)
	Utils.require(item.is_buyable(), "GameState.mark_shop_item_seen: item '%s' is not buyable" % id)
	_seen_shop_item_ids[id] = true


## Returns [code]true[/code] if adding [param amount] gold would not exceed [constant _MAX_GOLD].
func can_add_gold(amount: int) -> bool:
	return gold + amount <= _MAX_GOLD


## Returns [code]true[/code] if the player has at least [param amount] gold.
func can_spend_gold(amount: int) -> bool:
	return gold >= amount


## Adds [param amount] to [member gold].
## Crashes if [param amount] is not positive or if adding would exceed [constant _MAX_GOLD].
func add_gold(amount: int) -> void:
	Utils.require(amount > 0, "GameState.add_gold: amount must be positive, got %d" % amount)
	Utils.require(
		can_add_gold(amount),
		"GameState.add_gold: would exceed max gold (%d + %d > %d)" % [gold, amount, _MAX_GOLD]
	)
	gold += amount


## Subtracts [param amount] from [member gold].
## Crashes if [param amount] is not positive or if the player does not have enough gold.
func spend_gold(amount: int) -> void:
	Utils.require(amount > 0, "GameState.spend_gold: amount must be positive, got %d" % amount)
	Utils.require(
		can_spend_gold(amount), "GameState.spend_gold: not enough gold (%d < %d)" % [gold, amount]
	)
	gold -= amount


## Resets all state to defaults for a new game session.
## Call this before starting a new game so no state from a previous session leaks in.
func new_game() -> void:
	chapter = _DEFAULT_CHAPTER
	gold = _DEFAULT_GOLD
	_seen_shop_item_ids.clear()


## Returns state serialized for saving.
##
## Returned dictionary keys: [code]"chapter"[/code] ([int]),
## [code]"gold"[/code] ([int]), [code]"seen_shop_item_ids"[/code] ([Array] of [String]).
func get_save_data() -> Dictionary[String, Variant]:
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
## Fields are assigned in order ([member chapter], [member gold], then
## [member _seen_shop_item_ids]). [method Utils.require] calls [method OS.crash]
## on the first violation — the process terminates immediately, so partial state
## is never observable. A hard stop on corrupt data is preferred over continuing
## with inconsistent state.
## See: "res://docs/decisions/item_architecture.md" (Error handling philosophy).
func load_save(save_data: Dictionary[String, Variant]) -> void:
	chapter = _parse_chapter(save_data)
	gold = _parse_gold(save_data)
	_parse_seen_ids(save_data)


## Validates and returns the chapter value from [param save_data].
## Crashes on missing or non-integer value. Range is enforced by the [member chapter] setter.
func _parse_chapter(save_data: Dictionary[String, Variant]) -> int:
	var raw_chapter: Variant = save_data.get("chapter", null)
	var parsed_chapter: Variant = Utils.parse_json_int(raw_chapter)
	Utils.require(parsed_chapter != null, "GameState.load_save: invalid chapter '%s'" % raw_chapter)
	return parsed_chapter as int


## Validates and returns the gold value from [param save_data].
## Crashes on missing or non-integer value. Range is enforced by the [member gold] setter.
func _parse_gold(save_data: Dictionary[String, Variant]) -> int:
	var raw_gold: Variant = save_data.get("gold", null)
	var parsed_gold: Variant = Utils.parse_json_int(raw_gold)
	Utils.require(parsed_gold != null, "GameState.load_save: invalid gold '%s'" % raw_gold)
	return parsed_gold as int


## Validates and populates [member _seen_shop_item_ids] from [param save_data].
## Crashes on any invalid, unknown, or duplicate entry.
func _parse_seen_ids(save_data: Dictionary[String, Variant]) -> void:
	_seen_shop_item_ids.clear()

	var raw_seen: Variant = save_data.get("seen_shop_item_ids", null)
	Utils.require(raw_seen != null, "GameState.load_save: missing 'seen_shop_item_ids' key")
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
		# Crash on unknown or non-buyable IDs — save data is all-or-nothing. Silently
		# skipping stale IDs would mask corruption. If an item is removed, update or wipe the save.
		var seen_item: ItemData = ItemRegistry.get_item_or_crash(seen_id)
		Utils.require(
			seen_item.is_buyable(),
			"GameState.load_save: item '%s' in seen_shop_item_ids is not buyable" % seen_id
		)
		Utils.require(
			not _seen_shop_item_ids.has(seen_id),
			"GameState.load_save: duplicate id '%s' in seen_shop_item_ids" % seen_id
		)

		_seen_shop_item_ids[seen_id] = true
