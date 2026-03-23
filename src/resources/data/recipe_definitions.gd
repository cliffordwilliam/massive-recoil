class_name RecipeDefinitions
extends RefCounted
## Static recipe catalog. Each entry defines two ingredients that combine into a result.
##
## All ids must exist in [ItemDefinitions].
## All id values must be plain String literals — not StringName literals ([code]&"id"[/code]).
## [RecipeRegistry] validates ids with [code]is String[/code]; a StringName will fail that check.
##
## See: "res://docs/decisions/item_architecture.md"

## The full recipe catalog. Loaded and validated at startup by [RecipeRegistry].
const RECIPES: Array[Dictionary] = [
	{
		"ingredients": ["sterile_band", "antiseptic"],
		"result": "treat_band",
	},
	{
		"ingredients": ["sun_key_fragment", "moon_key_fragment"],
		"result": "sun_moon_key",
	},
	{
		"ingredients": ["ornate_pendant", "ruby_gem"],
		"result": "jeweled_pendant",
	},
]
