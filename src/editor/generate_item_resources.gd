@tool
class_name GenerateItemResources
extends EditorScript
## Editor utility that converts `items.json` into [ItemData] `.tres` resource files.
##
## This script reads item definitions from a JSON source file and generates
## corresponding [Resource] files that can be used directly by the game.
## Each entry in the JSON file is converted to an [ItemData] resource with its
## [member ItemData.type] set to the matching [enum ItemData.Type] value.
##
## The script is intended to be executed from the editor using
## [b]File > Run[/b] or [kbd]Ctrl + Shift + X[/kbd].
##
## Re-running the script clears all existing resources first, then regenerates
## them from JSON — so removed entries never leave stale files behind.
##
## Item type selection is determined by the `type` field in each JSON entry:
##
## | JSON type         | ItemData.Type                              |
## |-------------------|--------------------------------------------|
## | med               | [constant ItemData.Type.MED]               |
## | combinable_med    | [constant ItemData.Type.COMBINABLE_MED]    |
## | ammo              | [constant ItemData.Type.AMMO]              |
## | inventory_upgrade | [constant ItemData.Type.INVENTORY_UPGRADE] |
## | weapon            | [constant ItemData.Type.WEAPON]            |
## | weapon_upgrade    | [constant ItemData.Type.WEAPON_UPGRADE]    |
## | treasure          | [constant ItemData.Type.TREASURE]          |
## | key               | [constant ItemData.Type.KEY]               |
##
## Ammo type selection is determined by the `ammo_type` field (weapons only; use [code]""[/code]
## for non-weapons, which maps to [constant ItemData.AmmoType.NONE]):
##
## | JSON ammo_type | ItemData.AmmoType                         |
## |----------------|-------------------------------------------|
## | ""             | [constant ItemData.AmmoType.NONE]         |
## | handgun_ammo   | [constant ItemData.AmmoType.HANDGUN_AMMO] |
## | smg_ammo       | [constant ItemData.AmmoType.SMG_AMMO]     |
##
## Generated resources are written to [constant _OUTPUT_DIR].
##
## Each JSON item is validated: required keys present; [code]type[/code] and
## [code]ammo_type[/code] in allowed sets; numeric fields required, integers, positive,
## within bounds defined by [ItemData] schema constants; [code]id[/code], [code]name[/code],
## [code]description[/code] non-empty; [code]id[/code] unique.

## Path to the JSON source file containing item definitions.
const _SOURCE_PATH: String = "res://src/resources/data/items.json"

## Directory where generated `.tres` resources will be written.
const _OUTPUT_DIR: String = "res://src/resources/data/generated/items/"

const _TYPE_MAP: Dictionary = {
	"med": ItemData.Type.MED,
	"combinable_med": ItemData.Type.COMBINABLE_MED,
	"ammo": ItemData.Type.AMMO,
	"inventory_upgrade": ItemData.Type.INVENTORY_UPGRADE,
	"weapon": ItemData.Type.WEAPON,
	"weapon_upgrade": ItemData.Type.WEAPON_UPGRADE,
	"treasure": ItemData.Type.TREASURE,
	"key": ItemData.Type.KEY,
}

## Maps JSON ammo_type string to [enum ItemData.AmmoType].
const _AMMO_TYPE_MAP: Dictionary = {
	"": ItemData.AmmoType.NONE,
	"handgun_ammo": ItemData.AmmoType.HANDGUN_AMMO,
	"smg_ammo": ItemData.AmmoType.SMG_AMMO,
}

## Required keys for each item entry in the JSON. Used for shape validation.
## [code]ammo_type[/code] is required for all items — use [code]""[/code]
## for non-weapons (maps to [constant ItemData.AmmoType.NONE]).
const _REQUIRED_KEYS: Array[String] = [
	"ammo_type",
	"availability",
	"buy_price",
	"description",
	"id",
	"name",
	"sell_price",
	"size",
	"stack_size",
	"type"
]


## Entry point executed when the script is run from the editor.
##
## This function performs the following steps:
## 1. Ensures the output directory exists.
## 2. Reads and parses the JSON item database.
## 3. Validates every item entry. If any entry is invalid, all errors are reported
##    and the script exits without touching any existing resources.
## 4. Clears all existing [code].tres[/code] files from the output directory.
## 5. Builds and saves an [ItemData] resource for each entry.
##
## Nothing is written to disk unless every item passes validation.
func _run() -> void:
	if not _ensure_output_dir():
		return
	var items: Variant = _load_and_parse_items()
	if items == null:
		return
	items = items as Array
	# An empty items array is fine — this is a dev tool script and an empty
	# output directory is a perfectly valid result when items.json has no entries.

	# Pre-pass: check for id-level structural errors and duplicate IDs before
	# running full per-field validation. All errors are accumulated so that
	# every problem is reported in a single run — consistent with how
	# _validate_item works. Previously this used early return on the first
	# bad entry, which meant multiple problems required multiple runs to
	# discover. continue is now used instead so the loop always completes.
	var seen_ids: Dictionary = {}
	var pre_pass_valid: bool = true
	# Index loop instead of for-in so the item index is available for the
	# non-Dictionary error message below. All other errors in this pass include
	# an index or an id; without i the non-Dictionary case was the only one that
	# gave no location hint, making it harder to find the bad entry in items.json.
	for i: int in items.size():
		var item: Variant = items[i]
		if not item is Dictionary:
			push_error(
				"GenerateItemResources: items[%d] is not an object — found non-object entry." % i
			)
			pre_pass_valid = false
			continue
		var raw_id_val: Variant = (item as Dictionary).get("id", "")
		if not raw_id_val is String:
			push_error(
				(
					"GenerateItemResources: an item has a non-string id '%s' — no resources written."
					% raw_id_val
				)
			)
			pre_pass_valid = false
			continue
		var raw_id: String = raw_id_val as String
		if raw_id.is_empty():
			push_error(
				"GenerateItemResources: an item has an empty or missing id — no resources written."
			)
			pre_pass_valid = false
			continue
		if raw_id.contains("/") or raw_id.contains("\\") or raw_id.contains(".."):
			push_error(
				(
					"GenerateItemResources: id '%s' contains unsafe path characters — no resources written."
					% raw_id
				)
			)
			pre_pass_valid = false
			continue
		if seen_ids.has(raw_id):
			push_error("GenerateItemResources: duplicate id '%s' — no resources written." % raw_id)
			pre_pass_valid = false
			continue
		seen_ids[raw_id] = true
	if not pre_pass_valid:
		return

	var all_valid: bool = true
	for i: int in items.size():
		if not _validate_item(items[i], i):
			all_valid = false
	if not all_valid:
		push_error("GenerateItemResources: validation failed — no resources written.")
		return
	if not _clear_output_dir():
		return

	# Track successfully saved file names so we can roll back on failure.
	# This makes the write atomic: the output directory is either fully populated
	# or empty — never partially written. _clear_output_dir already ran above, so
	# any failure here leaves the directory empty rather than incomplete.
	var saved_names: Array[String] = []
	var save_failed: bool = false

	for i: int in items.size():
		var item: Dictionary = items[i] as Dictionary
		var res: ItemData = _build_resource(item)
		var file_name: String = str(item["id"]) + ".tres"
		var out_path: String = _OUTPUT_DIR + file_name
		var err: Error = ResourceSaver.save(res, out_path)
		if err != OK:
			push_error(
				(
					"GenerateItemResources: failed to save %s (error %d) — rolling back."
					% [out_path, err]
				)
			)
			save_failed = true
			break
		saved_names.append(file_name)
		print("GenerateItemResources: saved %s" % out_path)

	if save_failed:
		# Roll back by deleting every file written so far. Also attempt to remove
		# any .uid sidecar Godot may have created alongside the .tres file.
		#
		# False positive note: the rollback was flagged as potentially leaving the
		# output directory in a broken partial state if dir.remove() fails mid-loop.
		# This is already handled: the .tres removal result is checked explicitly
		# below, and on failure a clear error is pushed with an actionable recovery
		# instruction ("delete it manually before re-running"). The .uid sidecar
		# removal error is intentionally ignored because sidecars may legitimately
		# not exist. No silent failure path exists here.
		var dir: DirAccess = DirAccess.open(_OUTPUT_DIR)
		if dir:
			for name: String in saved_names:
				# Check the .tres removal explicitly: a failure here means the
				# output directory is left in a partial state and re-running the
				# script will not start from a clean slate. The .uid sidecar may
				# legitimately not exist, so its removal error is intentionally ignored.
				var rem_err: Error = dir.remove(name)
				if rem_err != OK:
					# "may be" → "is": if remove failed the file is definitely still
					# there, so the partial state is certain, not speculative. The
					# actionable instruction is added so the developer knows how to
					# recover without having to guess what to do next.
					var msg: String = (
						"GenerateItemResources: rollback could not remove '%s' — %s. "
						+ (
							"Output directory is in a partial state; delete it manually before re-running."
							% [name, error_string(rem_err)]
						)
					)
					push_error(msg)
				dir.remove(name + ".uid")
			push_error(
				"GenerateItemResources: rolled back — output directory is now empty. Re-run to regenerate."
			)
		else:
			var open_err_msg: String = (
				"GenerateItemResources: rollback failed — could not open output dir '%s' — %s. "
				+ (
					"Output directory may be in a partial state; delete it manually before re-running."
					% [_OUTPUT_DIR, error_string(DirAccess.get_open_error())]
				)
			)
			push_error(open_err_msg)
	else:
		print(
			(
				"GenerateItemResources: done — %d/%d resources saved."
				% [saved_names.size(), items.size()]
			)
		)

	# Scan runs unconditionally — after success to register the new files, and after
	# rollback to deregister any files the editor cached before they were removed.
	# Without it, stale .tres entries can linger in the FileSystem dock.
	EditorInterface.get_resource_filesystem().scan()


## Opens source JSON, parses it, returns [code]items[/code] array or [code]null[/code] on failure.
func _load_and_parse_items() -> Variant:
	var file: FileAccess = FileAccess.open(_SOURCE_PATH, FileAccess.READ)
	if file == null:
		push_error(
			(
				"GenerateItemResources: could not open %s — %s"
				% [_SOURCE_PATH, error_string(FileAccess.get_open_error())]
			)
		)
		return null
	var json_text: String = file.get_as_text()
	file.close()
	if json_text.is_empty():
		push_error("GenerateItemResources: %s is empty — nothing to generate." % _SOURCE_PATH)
		return null
	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary:
		push_error("GenerateItemResources: unexpected JSON structure in %s" % _SOURCE_PATH)
		return null
	var raw_items: Variant = (parsed as Dictionary).get("items", [])
	if not raw_items is Array:
		push_error("GenerateItemResources: 'items' must be an array in %s" % _SOURCE_PATH)
		return null
	return raw_items


## Validates that [param item] has the expected shape and valid values.
##
## Checks: required keys present; [code]type[/code] and [code]ammo_type[/code]
## in allowed sets; numeric fields required, integers, positive, within bounds
## (availability 1–4, prices 0–999999, stack 1–999, size width/height 1–6);
## [code]id[/code], [code]name[/code], [code]description[/code] non-empty;
## [code]name[/code] max 12 chars, [code]description[/code] max 50 chars;
## [code]id[/code] unique.
## Pushes an error for each failure and returns [code]false[/code] if any check fails.
##
## **Required keys and types:**
##
## | Key            | Type   | Constraints                                             |
## |----------------|--------|---------------------------------------------------------|
## | `id`           | string | Non-empty, unique across all items                      |
## | `name`         | string | Non-empty, max 12 characters                            |
## | `description`  | string | Non-empty, max 50 characters                            |
## | `type`         | string | One of: _TYPE_MAP                                       |
## | `ammo_type`    | string | One of: _AMMO_TYPE_MAP. Use `""` for non-weapons           |
## | `buy_price`    | int    | 0–999999                                                |
## | `sell_price`   | int    | 0–999999                                                |
## | `stack_size`   | int    | 1–999                                                   |
## | `availability` | int    | 1–4 (earliest chapter)                                  |
## | `size`         | object | Required; must have `width` and `height` (each int 1–6) |
func _validate_item(item: Variant, item_index: int) -> bool:
	if not item is Dictionary:
		push_error("GenerateItemResources: items[%d] is not a Dictionary — skipped." % item_index)
		return false

	var d: Dictionary = item as Dictionary
	# Declared here so every error message below uses item_id instead of
	# d.get("id", "?"). By the time _validate_item is called, _run() has already
	# verified that every entry has a non-empty string id, so this read is safe
	# and the "?" fallback is never needed.
	# as String cast is used here instead of str(): _run()'s pre-pass already
	# verified every entry has a non-empty String id, so the value is already a
	# String. str() would work but implies the value might not be a String, which
	# is misleading. The as-cast makes the known type explicit.
	var item_id: String = d.get("id", "") as String
	var valid: bool = true

	for key: String in _REQUIRED_KEYS:
		if not d.has(key):
			push_error(
				(
					"GenerateItemResources: item at index %d missing required key '%s' — skipped."
					% [item_index, key]
				)
			)
			valid = false

	if not valid:
		return false

	var type_str: String = d.get("type", "")
	if not _TYPE_MAP.has(type_str):
		push_error(
			(
				"GenerateItemResources: item '%s' has invalid type '%s' (index %d) — skipped."
				% [item_id, type_str, item_index]
			)
		)
		valid = false

	var raw_ammo_type: Variant = d.get("ammo_type")
	if not raw_ammo_type is String:
		push_error(
			(
				"GenerateItemResources: item '%s' ammo_type must be a string (index %d) — skipped."
				% [item_id, item_index]
			)
		)
		valid = false
	else:
		var ammo_key: String = raw_ammo_type as String
		if not _AMMO_TYPE_MAP.has(ammo_key):
			push_error(
				(
					"GenerateItemResources: item '%s' has invalid ammo_type '%s' (index %d) — skipped."
					% [item_id, ammo_key, item_index]
				)
			)
			valid = false
		# Guard on _TYPE_MAP.has(type_str) so this cross-check only fires when
		# type_str is itself valid. Without it, an invalid type that also has a
		# non-empty ammo_type would produce a second, misleading error claiming
		# the type is "not weapon" when the real problem is that the type is unknown.
		elif _TYPE_MAP.has(type_str) and type_str != "weapon" and ammo_key != "":
			var ammo_err: String = (
				"GenerateItemResources: item '%s' has ammo_type '%s' but type is '%s', "
				+ "not weapon (index %d) — skipped." % [item_id, ammo_key, type_str, item_index]
			)
			push_error(ammo_err)
			valid = false
		# NOTE: a weapon with ammo_type "" (→ AmmoType.NONE) is intentionally valid.
		# A weapon without an ammo type has infinite ammo by design — used for
		# weapons that never consume a resource (e.g. end-game gifts). No error
		# is raised for this case.

	# Parse once here and reuse below. Using parse_json_int rather than int()
	# avoids silent coercion: int("abc") returns 0, whereas parse_json_int returns
	# null, which the checks below correctly treat as invalid.
	var parsed_buy_price: Variant = Utils.parse_json_int(d.get("buy_price", null))
	var parsed_sell_price: Variant = Utils.parse_json_int(d.get("sell_price", null))
	var parsed_stack: Variant = Utils.parse_json_int(d.get("stack_size", null))
	var parsed_avail: Variant = Utils.parse_json_int(d.get("availability", null))

	if (
		parsed_buy_price == null
		or (parsed_buy_price as int) < ItemSchema.MIN_PRICE
		or (parsed_buy_price as int) > ItemSchema.MAX_PRICE
	):
		push_error(
			(
				"GenerateItemResources: item '%s' buy_price must be integer in [%d, %d] (index %d) — skipped."
				% [item_id, ItemSchema.MIN_PRICE, ItemSchema.MAX_PRICE, item_index]
			)
		)
		valid = false
	if (
		parsed_sell_price == null
		or (parsed_sell_price as int) < ItemSchema.MIN_PRICE
		or (parsed_sell_price as int) > ItemSchema.MAX_PRICE
	):
		push_error(
			(
				"GenerateItemResources: item '%s' sell_price must be integer in [%d, %d] (index %d) — skipped."
				% [item_id, ItemSchema.MIN_PRICE, ItemSchema.MAX_PRICE, item_index]
			)
		)
		valid = false
	if (
		parsed_stack == null
		or (parsed_stack as int) < ItemSchema.MIN_STACK
		or (parsed_stack as int) > ItemSchema.MAX_STACK
	):
		push_error(
			(
				"GenerateItemResources: item '%s' stack_size must be integer in [%d, %d] (index %d) — skipped."
				% [item_id, ItemSchema.MIN_STACK, ItemSchema.MAX_STACK, item_index]
			)
		)
		valid = false
	if (
		parsed_avail == null
		or (parsed_avail as int) < ItemSchema.MIN_AVAILABILITY
		or (parsed_avail as int) > ItemSchema.MAX_AVAILABILITY
	):
		var avail_err: String = (
			"GenerateItemResources: item '%s' availability must be integer in [%d, %d] "
			+ (
				"(index %d) — skipped."
				% [item_id, ItemSchema.MIN_AVAILABILITY, ItemSchema.MAX_AVAILABILITY, item_index]
			)
		)
		push_error(avail_err)
		valid = false

	var size_val: Variant = d.get("size", {})
	if not size_val is Dictionary:
		var size_err: String = (
			"GenerateItemResources: item '%s' key 'size' must be an object with "
			+ "width/height (index %d) — skipped." % [item_id, item_index]
		)
		push_error(size_err)
		valid = false
	else:
		var size_dict: Dictionary = size_val as Dictionary
		for dim: String in ["width", "height"]:
			if not size_dict.has(dim):
				push_error(
					(
						"GenerateItemResources: item '%s' size missing '%s' (index %d) — skipped."
						% [item_id, dim, item_index]
					)
				)
				valid = false
			else:
				# Parse once and reuse for both the type check and the range check.
				# This avoids calling int() on the raw value after confirming it is a
				# valid integer — int() silently coerces bad values (e.g. "4px" → 0)
				# whereas parse_json_int returns null, making the problem visible.
				var parsed_dim: Variant = Utils.parse_json_int(size_dict.get(dim, null))
				if parsed_dim == null:
					push_error(
						(
							"GenerateItemResources: item '%s' size.%s must be an integer (index %d) — skipped."
							% [item_id, dim, item_index]
						)
					)
					valid = false
				else:
					var dim_val: int = parsed_dim as int
					if dim_val < ItemSchema.MIN_SIZE_DIM or dim_val > ItemSchema.MAX_SIZE_DIM:
						push_error(
							(
								"GenerateItemResources: item '%s' size.%s must be in [%d, %d], got %d (index %d) — skipped."
								% [
									item_id,
									dim,
									ItemSchema.MIN_SIZE_DIM,
									ItemSchema.MAX_SIZE_DIM,
									dim_val,
									item_index
								]
							)
						)
						valid = false

	var raw_name: Variant = d.get("name", "")
	if not raw_name is String:
		push_error(
			(
				"GenerateItemResources: item '%s' name must be a string (index %d) — skipped."
				% [item_id, item_index]
			)
		)
		valid = false
	else:
		var name_str: String = raw_name as String
		if name_str.is_empty():
			push_error(
				(
					"GenerateItemResources: item '%s' name must not be empty (index %d) — skipped."
					% [item_id, item_index]
				)
			)
			valid = false
		elif name_str.length() > ItemSchema.MAX_NAME_LENGTH:
			push_error(
				(
					"GenerateItemResources: item '%s' name must be max %d chars, got %d (index %d) — skipped."
					% [item_id, ItemSchema.MAX_NAME_LENGTH, name_str.length(), item_index]
				)
			)
			valid = false

	var raw_desc: Variant = d.get("description", "")
	if not raw_desc is String:
		push_error(
			(
				"GenerateItemResources: item '%s' description must be a string (index %d) — skipped."
				% [item_id, item_index]
			)
		)
		valid = false
	else:
		var desc_str: String = raw_desc as String
		if desc_str.is_empty():
			push_error(
				(
					"GenerateItemResources: item '%s' description must not be empty (index %d) — skipped."
					% [item_id, item_index]
				)
			)
			valid = false
		elif desc_str.length() > ItemSchema.MAX_DESCRIPTION_LENGTH:
			var desc_err: String = (
				"GenerateItemResources: item '%s' description must be max %d chars, "
				+ (
					"got %d (index %d) — skipped."
					% [item_id, ItemSchema.MAX_DESCRIPTION_LENGTH, desc_str.length(), item_index]
				)
			)
			push_error(desc_err)
			valid = false

	return valid


## Creates and populates an [ItemData] resource from a validated JSON item entry.
##
## The [member ItemData.type] is determined by the `type` field in the JSON entry.
##
## Uses [method Object.set] for all property assignments to avoid stale script
## cache issues in the editor when scripts have changed but not yet reloaded.
##
## Assumes [param item] has already passed [method _validate_item].
func _build_resource(item: Dictionary) -> ItemData:
	var type_str: String = item.get("type", "")
	var res: ItemData = ItemData.new()

	res.set("type", _TYPE_MAP[type_str])
	# Explicit StringName conversion: ItemData.id is declared as StringName.
	# Assigning a plain String via res.set() relies on implicit coercion, which
	# works for == comparisons but can silently fail in Dictionary lookups keyed
	# by StringName — the primary use of this id at runtime in ItemRegistry.
	res.set("id", StringName(item.get("id", "") as String))
	# JSON uses "name" but the property is "ui_name" to avoid shadowing Godot's
	# built-in Node.name. The rename happens here, at the boundary between the
	# JSON schema and the ItemData resource schema.
	res.set("ui_name", item.get("name", ""))
	res.set("description", item.get("description", ""))
	# _validate_item already confirmed every numeric field is a valid integer.
	# Using parse_json_int here (not bare int()) matches the validation pass —
	# both parse with the same semantics. int() silently coerces non-integer
	# values (e.g. "4px" → 0), which could mask a broken validation step;
	# parse_json_int returns null for invalid inputs.
	# Note: in GDScript 4, null as int evaluates to 0 (default primitive) —
	# it does not crash. So if parse_json_int returned null here the resource
	# field would silently be 0, not a hard failure. This path is unreachable
	# in practice because _validate_item always runs first. The real benefit
	# of using parse_json_int in both passes is consistency: the same parser
	# accepts or rejects inputs in both places, preventing a subtle gap if
	# their semantics ever diverged.
	res.set("buy_price", Utils.parse_json_int(item.get("buy_price")) as int)
	res.set("sell_price", Utils.parse_json_int(item.get("sell_price")) as int)
	res.set("stack_size", Utils.parse_json_int(item.get("stack_size")) as int)
	res.set("availability", Utils.parse_json_int(item.get("availability")) as int)
	res.set("ammo_type", _AMMO_TYPE_MAP.get(item.get("ammo_type", ""), ItemData.AmmoType.NONE))

	var size_dict: Dictionary = item.get("size", {})
	# Same reasoning as above: parse_json_int instead of int() so a broken
	# validation step would crash here rather than silently produce a zero.
	(
		res
		. set(
			"inventory_size",
			Vector2i(
				Utils.parse_json_int(size_dict.get("width")) as int,
				Utils.parse_json_int(size_dict.get("height")) as int,
			)
		)
	)

	return res


## Ensures the output directory exists, creating it if necessary.
## Returns [code]false[/code] and pushes an error if the directory cannot be created.
func _ensure_output_dir() -> bool:
	# Use DirAccess.open to check existence — consistent with _clear_output_dir.
	# make_dir_recursive_absolute requires an absolute path, so globalize_path is
	# only used there, not for the existence check.
	if DirAccess.open(_OUTPUT_DIR) != null:
		return true
	var err: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(_OUTPUT_DIR)
	)
	if err != OK:
		push_error(
			(
				"GenerateItemResources: could not create output dir %s — %s"
				% [_OUTPUT_DIR, error_string(err)]
			)
		)
		return false
	return true


## Deletes all [code].tres[/code] and [code].uid[/code] files in [constant _OUTPUT_DIR]
## before regenerating, so removed JSON entries do not leave stale resources behind.
## Returns [code]false[/code] and pushes an error if the directory cannot be opened or
## if any file cannot be removed (e.g. locked by Godot's resource cache).
func _clear_output_dir() -> bool:
	var dir: DirAccess = DirAccess.open(_OUTPUT_DIR)
	if dir == null:
		push_error(
			(
				"GenerateItemResources: could not open output dir %s — %s"
				% [_OUTPUT_DIR, error_string(DirAccess.get_open_error())]
			)
		)
		return false
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".uid"):
			var err: Error = dir.remove(file_name)
			if err != OK:
				push_error(
					(
						"GenerateItemResources._clear_output_dir: failed to remove '%s' — %s"
						% [file_name, error_string(err)]
					)
				)
				dir.list_dir_end()
				return false
		file_name = dir.get_next()
	dir.list_dir_end()
	return true
