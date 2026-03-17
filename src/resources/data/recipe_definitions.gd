class_name RecipeDefinitions
extends RefCounted
## Static recipe catalog. Each entry defines two ingredients that combine into a result.
##
## All ids must exist in [ItemDefinitions].

const RECIPES: Array = [
	{
		"ingredients": ["sterile_band", "antiseptic"],
		"result": "treat_band",
	},
	{
		"ingredients": ["sun_emblem_fragment", "moon_emblem_fragment"],
		"result": "sun_moon_emblem",
	},
	{
		"ingredients": ["ornate_pendant", "ruby_gem"],
		"result": "jeweled_pendant",
	},
]
