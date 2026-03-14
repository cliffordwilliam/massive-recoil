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
## Ammo type selection is determined by the `ammo_type` field (weapons only; null or omitted =
## [constant ItemData.AmmoType.NONE]):
##
## | JSON ammo_type | ItemData.AmmoType                         |
## |----------------|-------------------------------------------|
## | null / omitted | [constant ItemData.AmmoType.NONE]         |
## | handgun_ammo   | [constant ItemData.AmmoType.HANDGUN_AMMO] |
## | smg_ammo       | [constant ItemData.AmmoType.SMG_AMMO]     |
##
## Generated resources are written to [constant _OUTPUT_DIR].
##
## Each JSON item is validated: required keys present; [code]type[/code] and
## [code]ammo_type[/code] in allowed sets; numeric fields required, integers, positive,
## within bounds (availability 1–4, prices and stack 0–999999 / 1–999, size width/height 1–6);
## [code]id[/code], [code]name[/code], [code]description[/code] non-empty; [code]name[/code]
## max 12 chars, [code]description[/code] max 50 chars; [code]id[/code] unique.

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

## Maps JSON ammo_type string (or null) to [enum ItemData.AmmoType].
const _AMMO_TYPE_MAP: Dictionary = {
	"": ItemData.AmmoType.NONE,
	"handgun_ammo": ItemData.AmmoType.HANDGUN_AMMO,
	"smg_ammo": ItemData.AmmoType.SMG_AMMO,
}

## Required keys for each item entry in the JSON. Used for shape validation.
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

## Max length for [code]name[/code] (display name) in characters.
const _MAX_NAME_LENGTH: int = 12
## Max length for [code]description[/code] in characters.
const _MAX_DESCRIPTION_LENGTH: int = 50
## Numeric bounds: all numeric fields are required and must be positive.
const _MIN_PRICE: int = 0
const _MAX_PRICE: int = 999999
const _MIN_STACK: int = 1
const _MAX_STACK: int = 999
const _MIN_AVAILABILITY: int = 1
const _MAX_AVAILABILITY: int = 4
const _MIN_SIZE_DIM: int = 1
const _MAX_SIZE_DIM: int = 6


## Entry point executed when the script is run from the editor.
##
## This function performs the following steps:
## 1. Ensures the output directory exists.
## 2. Clears all existing [code].tres[/code] files from the output directory.
## 3. Reads and parses the JSON item database.
## 4. For each item: validates shape and values (required keys, valid type/ammo_type,
##    integer numbers, [code]size.width[/code]/[code]size.height[/code], name/description
##    length limits, unique id); skips invalid entries and reports errors.
## 5. Builds an [ItemData] resource for each valid entry.
## 6. Saves the generated [code].tres[/code] file to disk.
##
## Invalid or malformed entries are skipped and reported in the editor output.
func _run() -> void:
	_ensure_output_dir()
	_clear_output_dir()

	var json_text: String = FileAccess.get_file_as_string(_SOURCE_PATH)
	if json_text.is_empty():
		var err: Error = FileAccess.get_open_error()
		push_error(
			"GenerateItemResources: could not read %s — %s" % [_SOURCE_PATH, error_string(err)]
		)
		return

	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary:
		push_error("GenerateItemResources: unexpected JSON structure in %s" % _SOURCE_PATH)
		return

	var items: Array = (parsed as Dictionary).get("items", [])
	var saved: int = 0
	var seen_ids: Dictionary = {}

	for i: int in items.size():
		var raw: Variant = items[i]
		if not _validate_item(raw, i, seen_ids):
			continue
		var item: Dictionary = raw as Dictionary
		var res: ItemData = _build_resource(item)
		if res == null:
			continue

		var out_path: String = _OUTPUT_DIR + str(item["id"]) + ".tres"
		var err: Error = ResourceSaver.save(res, out_path)
		if err != OK:
			push_error("GenerateItemResources: failed to save %s (error %d)" % [out_path, err])
		else:
			saved += 1
			print("GenerateItemResources: saved %s" % out_path)

	print("GenerateItemResources: done — %d/%d resources saved." % [saved, items.size()])
	EditorInterface.get_resource_filesystem().scan()


## Creates and populates an [ItemData] resource from a single JSON item entry.
##
## The [member ItemData.type] is determined by the `type` field in the JSON entry.
##
## Uses [method Object.set] for all property assignments to avoid stale script
## cache issues in the editor when scripts have changed but not yet reloaded.
##
## Validates that [param item] has the expected shape and valid values.
##
## Checks: required keys present; [code]type[/code] and [code]ammo_type[/code]
## in allowed sets; numeric fields required, integers, positive, within bounds
## (availability 1–4, prices 0–999999, stack 1–999, size width/height 1–6);
## [code]id[/code], [code]name[/code], [code]description[/code] non-empty;
## [code]name[/code] max 12 chars, [code]description[/code] max 50 chars;
## [code]id[/code] unique (pass [param seen_ids] to track; updated when valid).
## Pushes an error for each failure and returns [code]false[/code] if any check fails.
##
## **Required keys and types:**
##
## | Key            | Type   | Constraints                                                       |
## |----------------|--------|---------------------------------------------------------|
## | `id`           | string | Non-empty, unique across all items                      |
## | `name`         | string | Non-empty, max 12 characters                            |
## | `description`  | string | Non-empty, max 50 characters                            |
## | `type`         | string | One of: _TYPE_MAP                                       |
## | `ammo_type`    | string | One of: _AMMO_TYPE_MAP                                  |
## | `buy_price`    | int    | 0–999999                                                |
## | `sell_price`   | int    | 0–999999                                                |
## | `stack_size`   | int    | 1–999                                                   |
## | `availability` | int    | 1–4 (earliest chapter)                                  |
## | `size`         | object | Required; must have `width` and `height` (each int 1–6) |
func _validate_item(item: Variant, item_index: int, seen_ids: Dictionary) -> bool:
	if not item is Dictionary:
		push_error("GenerateItemResources: items[%d] is not a Dictionary — skipped." % item_index)
		return false

	var d: Dictionary = item as Dictionary
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
				% [d.get("id", "?"), type_str, item_index]
			)
		)
		valid = false

	var raw_ammo: Variant = d.get("ammo_type", "")
	var ammo_key: String = "" if raw_ammo == null else str(raw_ammo)
	if not _AMMO_TYPE_MAP.has(ammo_key):
		push_error(
			(
				"GenerateItemResources: item '%s' has invalid ammo_type '%s' (index %d) — skipped."
				% [d.get("id", "?"), ammo_key, item_index]
			)
		)
		valid = false

	var buy_price_val: int = int(d.get("buy_price", -1))
	var sell_price_val: int = int(d.get("sell_price", -1))
	var stack_val: int = int(d.get("stack_size", -1))
	var avail_val: int = int(d.get("availability", -1))

	if (
		not _is_json_int(d.get("buy_price", null))
		or buy_price_val < _MIN_PRICE
		or buy_price_val > _MAX_PRICE
	):
		push_error(
			(
				"GenerateItemResources: item '%s' buy_price must be integer in [%d, %d] (index %d) — skipped."
				% [d.get("id", "?"), _MIN_PRICE, _MAX_PRICE, item_index]
			)
		)
		valid = false
	if (
		not _is_json_int(d.get("sell_price", null))
		or sell_price_val < _MIN_PRICE
		or sell_price_val > _MAX_PRICE
	):
		push_error(
			(
				"GenerateItemResources: item '%s' sell_price must be integer in [%d, %d] (index %d) — skipped."
				% [d.get("id", "?"), _MIN_PRICE, _MAX_PRICE, item_index]
			)
		)
		valid = false
	if (
		not _is_json_int(d.get("stack_size", null))
		or stack_val < _MIN_STACK
		or stack_val > _MAX_STACK
	):
		push_error(
			(
				"GenerateItemResources: item '%s' stack_size must be integer in [%d, %d] (index %d) — skipped."
				% [d.get("id", "?"), _MIN_STACK, _MAX_STACK, item_index]
			)
		)
		valid = false
	if (
		not _is_json_int(d.get("availability", null))
		or avail_val < _MIN_AVAILABILITY
		or avail_val > _MAX_AVAILABILITY
	):
		push_error(
			(
				"GenerateItemResources: item '%s' availability must be integer "
				+ (
					"in [%d, %d] (index %d) — skipped."
					% [d.get("id", "?"), _MIN_AVAILABILITY, _MAX_AVAILABILITY, item_index]
				)
			)
		)
		valid = false

	var size_val: Variant = d.get("size", {})
	if not size_val is Dictionary:
		push_error(
			(
				"GenerateItemResources: item '%s' key 'size' must be an object "
				+ "with width/height (index %d) — skipped." % [d.get("id", "?"), item_index]
			)
		)
		valid = false
	else:
		var size_dict: Dictionary = size_val as Dictionary
		for dim: String in ["width", "height"]:
			if not size_dict.has(dim):
				push_error(
					(
						"GenerateItemResources: item '%s' size missing '%s' (index %d) — skipped."
						% [d.get("id", "?"), dim, item_index]
					)
				)
				valid = false
			elif not _is_json_int(size_dict.get(dim, null)):
				push_error(
					(
						"GenerateItemResources: item '%s' size.%s must be an integer (index %d) — skipped."
						% [d.get("id", "?"), dim, item_index]
					)
				)
				valid = false
			else:
				var dim_val: int = int(size_dict.get(dim, 0))
				if dim_val < _MIN_SIZE_DIM or dim_val > _MAX_SIZE_DIM:
					push_error(
						(
							"GenerateItemResources: item '%s' size.%s must be in [%d, %d], got %d (index %d) — skipped."
							% [
								d.get("id", "?"),
								dim,
								_MIN_SIZE_DIM,
								_MAX_SIZE_DIM,
								dim_val,
								item_index
							]
						)
					)
					valid = false

	var item_id: String = str(d.get("id", ""))
	if item_id.is_empty():
		push_error("GenerateItemResources: item at index %d has empty id — skipped." % item_index)
		valid = false
	elif seen_ids.has(item_id):
		push_error(
			"GenerateItemResources: duplicate id '%s' (index %d) — skipped." % [item_id, item_index]
		)
		valid = false

	var name_str: String = str(d.get("name", ""))
	if name_str.is_empty():
		push_error(
			(
				"GenerateItemResources: item '%s' name must not be empty (index %d) — skipped."
				% [item_id if not item_id.is_empty() else "?", item_index]
			)
		)
		valid = false
	elif name_str.length() > _MAX_NAME_LENGTH:
		push_error(
			(
				"GenerateItemResources: item '%s' name must be max %d chars, got %d (index %d) — skipped."
				% [d.get("id", "?"), _MAX_NAME_LENGTH, name_str.length(), item_index]
			)
		)
		valid = false

	var desc_str: String = str(d.get("description", ""))
	if desc_str.is_empty():
		push_error(
			(
				"GenerateItemResources: item '%s' description must not be empty (index %d) — skipped."
				% [d.get("id", "?"), item_index]
			)
		)
		valid = false
	elif desc_str.length() > _MAX_DESCRIPTION_LENGTH:
		push_error(
			(
				"GenerateItemResources: item '%s' description must be max %d chars, "
				+ (
					"got %d (index %d) — skipped."
					% [d.get("id", "?"), _MAX_DESCRIPTION_LENGTH, desc_str.length(), item_index]
				)
			)
		)
		valid = false

	if valid:
		seen_ids[item_id] = true
	return valid


## Returns [code]true[/code] if [param v] is a JSON number that represents an integer.
static func _is_json_int(v: Variant) -> bool:
	if v is int:
		return true
	if v is float:
		var f: float = v as float
		return is_equal_approx(f, floor(f))
	return false


## Creates and populates an [ItemData] resource from a single JSON item entry.
##
## The [member ItemData.type] is determined by the `type` field in the JSON entry.
##
## Uses [method Object.set] for all property assignments to avoid stale script
## cache issues in the editor when scripts have changed but not yet reloaded.
##
## Returns the populated [ItemData] resource, or [code]null[/code] if the entry
## is invalid or has an unrecognised type.
func _build_resource(item: Dictionary) -> ItemData:
	var type_str: String = item.get("type", "")

	if not _TYPE_MAP.has(type_str):
		push_error(
			(
				"GenerateItemResources: item '%s' has unknown type '%s' — skipped."
				% [item.get("id", "?"), type_str]
			)
		)
		return null

	var res: ItemData = ItemData.new()

	res.set("type", _TYPE_MAP[type_str])
	res.set("id", item.get("id", ""))
	res.set("display_name", item.get("name", ""))
	res.set("description", item.get("description", ""))
	res.set("buy_price", int(item.get("buy_price", 0)))
	res.set("sell_price", int(item.get("sell_price", 0)))
	res.set("stack_size", int(item.get("stack_size", 1)))
	res.set("availability", int(item.get("availability", 1)))
	var raw_ammo: Variant = item.get("ammo_type", "")
	var ammo_key: String = "" if raw_ammo == null else str(raw_ammo)
	res.set("ammo_type", _AMMO_TYPE_MAP.get(ammo_key, ItemData.AmmoType.NONE))

	var size_dict: Dictionary = item.get("size", {})
	res.set(
		"inventory_size", Vector2i(int(size_dict.get("width", 1)), int(size_dict.get("height", 1)))
	)

	return res


func _ensure_output_dir() -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(_OUTPUT_DIR)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_OUTPUT_DIR))


## Deletes all [code].tres[/code] and [code].uid[/code] files in [constant _OUTPUT_DIR]
## before regenerating, so removed JSON entries do not leave stale resources behind.
func _clear_output_dir() -> void:
	var dir: DirAccess = DirAccess.open(_OUTPUT_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".uid"):
			dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
