class_name RecipeDefinitions
extends RefCounted
## Static recipe catalog. Maps each result id to its two ingredient ids.
##
## All ids must exist in [ItemDefinitions].
##
## See: "res://docs/decisions/item_architecture.md"

## The full recipe catalog. Loaded and validated at startup by [RecipeRegistry].
## Keys are result ids; values are two-element ingredient arrays.
## Array values cannot be typed [code]Array[StringName][/code] — nested typed collections
## are not supported in GDScript. See: "res://docs/godot/can_we_use_nested_type.md"
const RECIPES: Dictionary[StringName, Array] = {
	&"treat_band": [&"sterile_band", &"antiseptic"],
	&"sun_moon_key": [&"sun_key_fragment", &"moon_key_fragment"],
	&"jeweled_pendant": [&"ornate_pendant", &"ruby_gem"],
}
