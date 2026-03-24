class_name RecipeDefinitions
extends RefCounted
## Static recipe catalog. Maps each result id to its two ingredient ids.
##
## All ids must exist in [ItemDefinitions].
## All id values must be plain String literals — not StringName literals ([code]&"id"[/code]).
## [RecipeRegistry] validates ingredient ids with [code]is String[/code];
## a StringName will fail that check.
##
## See: "res://docs/decisions/item_architecture.md"

## The full recipe catalog. Loaded and validated at startup by [RecipeRegistry].
## Keys are result ids; values are two-element ingredient arrays.
const RECIPES: Dictionary[String, Array] = {
	"treat_band": ["sterile_band", "antiseptic"],
	"sun_moon_key": ["sun_key_fragment", "moon_key_fragment"],
	"jeweled_pendant": ["ornate_pendant", "ruby_gem"],
}
