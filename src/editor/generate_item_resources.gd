@tool
class_name GenerateItemResources
extends EditorScript
## Editor utility that converts `items.json` into typed `.tres` resource files.
##
## This script reads item definitions from a JSON source file and generates
## corresponding [Resource] files that can be used directly by the game.
## Each entry in the JSON file is converted to a concrete subclass of
## [ShopItemData] depending on which price fields are defined.
##
## The script is intended to be executed from the editor using
## [b]File > Run[/b] or [kbd]Ctrl + Shift + X[/kbd].
##
## Re-running the script overwrites previously generated resources.
##
## Item type selection is determined by the presence of price fields:
##
## | buy_price | sell_price | Resource Type     |
## |-----------|------------|-------------------|
## | set       | set        | [BuySellItemData] |
## | null      | set        | [SellOnlyItemData]|
## | set       | null       | [BuyOnlyItemData] |
##
## Generated resources are written to [constant _OUTPUT_DIR].

## Path to the JSON source file containing item definitions.
const _SOURCE_PATH: String = "res://src/resources/data/items.json"

## Directory where generated `.tres` resources will be written.
const _OUTPUT_DIR: String = "res://src/resources/data/generated/items/"


## Entry point executed when the script is run from the editor.
##
## This function performs the following steps:
## 1. Ensures the output directory exists.
## 2. Reads and parses the JSON item database.
## 3. Iterates through all item entries.
## 4. Builds the appropriate [ShopItemData] resource.
## 5. Saves the generated `.tres` file to disk.
##
## Invalid or malformed entries are skipped and reported in the editor output.
func _run() -> void:
	_ensure_output_dir()

	var json_text: String = FileAccess.get_file_as_string(_SOURCE_PATH)
	if json_text.is_empty():
		push_error("GenerateItemResources: could not read %s" % _SOURCE_PATH)
		return

	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary:
		push_error("GenerateItemResources: unexpected JSON structure in %s" % _SOURCE_PATH)
		return

	var items: Array = (parsed as Dictionary).get("items", [])
	var saved: int = 0

	for raw: Dictionary in items:
		var item: Dictionary = raw as Dictionary
		var res: ShopItemData = _build_resource(item)
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


## Creates and populates the appropriate [ShopItemData] subclass
## from a single JSON item entry.
##
## The subclass created depends on which pricing fields are present:
##
## - [BuySellItemData] if both `buy_price` and `sell_price` exist.
## - [SellOnlyItemData] if only `sell_price` exists.
## - [BuyOnlyItemData] if only `buy_price` exists.
##
## If neither field is present the item is considered invalid and skipped.
##
## Inherited properties are assigned using [method Object.set] instead of
## direct property access to avoid stale script cache issues in the editor
## when base class scripts have changed but not yet reloaded.
##
## Returns the populated [ShopItemData] resource or `null` if the item
## definition is invalid.
func _build_resource(item: Dictionary) -> ShopItemData:
	var buy: float = item.get("buy_price")
	var sell: float = item.get("sell_price")

	var res: ShopItemData
	if buy != null and sell != null:
		var r: BuySellItemData = BuySellItemData.new()
		r.buy_price = int(buy)
		r.sell_price = int(sell)
		res = r
	elif sell != null:
		var r: SellOnlyItemData = SellOnlyItemData.new()
		r.sell_price = int(sell)
		res = r
	elif buy != null:
		var r: BuyOnlyItemData = BuyOnlyItemData.new()
		r.buy_price = int(buy)
		res = r
	else:
		push_error(
			(
				"GenerateItemResources: item '%s' has no buy_price or sell_price — skipped."
				% item.get("id", "?")
			)
		)
		return null

	# Use set() for inherited properties to avoid stale script cache issues
	# when the editor has not yet reloaded modified base class scripts.
	res.set("id", item.get("id", ""))
	res.set("display_name", item.get("name", ""))
	res.set("description", item.get("description", ""))
	res.set("stack_size", int(item.get("stack_size", 1)))
	res.set("availability", int(item.get("availability", 1)))

	var size_dict: Dictionary = item.get("size", {})
	res.set(
		"inventory_size", Vector2i(int(size_dict.get("width", 0)), int(size_dict.get("height", 0)))
	)

	return res


func _ensure_output_dir() -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(_OUTPUT_DIR)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_OUTPUT_DIR))
