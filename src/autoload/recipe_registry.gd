# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the RecipeRegistry autoload
extends Node
## Validated recipe catalog. Provides ingredient-pair → result lookups.
##
## Loads recipes from [RecipeDefinitions] at startup, validates all ingredient
## and result IDs against [ItemRegistry], and builds an order-independent lookup
## table for the combine system.
##
## Must be registered in Project Settings after [code]ItemRegistry[/code].

## Maps a canonical ingredient-pair key (see [method _make_key]) to a result id.
var _recipes: Dictionary[String, StringName] = {}


func _ready() -> void:
	for recipe: Dictionary in RecipeDefinitions.RECIPES:
		var ingredients: Variant = recipe.get("ingredients", null)
		Utils.require(
			ingredients is Array and (ingredients as Array).size() == 2,
			"RecipeDefinitions: each recipe must have exactly 2 ingredients"
		)
		var arr: Array = ingredients as Array
		Utils.require(
			arr[0] is String and not (arr[0] as String).is_empty(),
			"RecipeDefinitions: ingredient must be a non-empty String"
		)
		Utils.require(
			arr[1] is String and not (arr[1] as String).is_empty(),
			"RecipeDefinitions: ingredient must be a non-empty String"
		)
		var id_a: StringName = StringName(arr[0] as String)
		var id_b: StringName = StringName(arr[1] as String)

		var result_raw: Variant = recipe.get("result", null)
		Utils.require(
			result_raw is String and not (result_raw as String).is_empty(),
			"RecipeDefinitions: result must be a non-empty String"
		)
		var result_id: StringName = StringName(result_raw as String)

		ItemRegistry.validate_item_id(id_a)
		ItemRegistry.validate_item_id(id_b)
		ItemRegistry.validate_item_id(result_id)

		var key: String = _make_key(id_a, id_b)
		Utils.require(
			not _recipes.has(key),
			"RecipeDefinitions: duplicate recipe for ingredients '%s' + '%s'" % [id_a, id_b]
		)
		_recipes[key] = result_id


## Returns the result item id when combining [param id_a] and [param id_b].
## Returns an empty [StringName] if no recipe exists for this pair.
## Ingredient order does not matter.
func get_result(id_a: StringName, id_b: StringName) -> StringName:
	return _recipes.get(_make_key(id_a, id_b), &"")


## Returns [code]true[/code] if a recipe exists for combining [param id_a] and [param id_b].
## Ingredient order does not matter.
func has_recipe(id_a: StringName, id_b: StringName) -> bool:
	return _recipes.has(_make_key(id_a, id_b))


## Returns a canonical, order-independent key for an ingredient pair.
## Sorting by string value ensures [code]_make_key(a, b) == _make_key(b, a)[/code].
func _make_key(id_a: StringName, id_b: StringName) -> String:
	if str(id_a) <= str(id_b):
		return str(id_a) + "|" + str(id_b)
	return str(id_b) + "|" + str(id_a)
