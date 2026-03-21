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
	Utils.require(
		ItemRegistry.is_node_ready(), "RecipeRegistry: needs ItemRegistry autoload to be ready."
	)

	for recipe: Dictionary in RecipeDefinitions.RECIPES:
		var ids: Array[StringName] = _validate_recipe(recipe)
		var id_a: StringName = ids[0]
		var id_b: StringName = ids[1]
		var result_id: StringName = ids[2]
		var key: String = _make_key(id_a, id_b)

		Utils.require(
			not _recipes.has(key),
			"RecipeDefinitions: duplicate recipe for ingredients '%s' and '%s'" % [id_a, id_b]
		)

		_recipes[key] = result_id


## Returns the result item id when combining [param id_a] and [param id_b].
## Returns an empty [StringName] ([code]&""[/code]) if no recipe exists for this pair.
## Use [method has_recipe] when you only need existence; use this when you need the result id.
## Ingredient order does not matter.
func get_result(id_a: StringName, id_b: StringName) -> StringName:
	return _recipes.get(_make_key(id_a, id_b), &"")


## Returns [code]true[/code] if a recipe exists for combining [param id_a] and [param id_b].
## Prefer this over checking [method get_result] against [code]&""[/code]
## when you only need existence.
## Ingredient order does not matter.
func has_recipe(id_a: StringName, id_b: StringName) -> bool:
	return _recipes.has(_make_key(id_a, id_b))


## Returns a canonical, order-independent key for an ingredient pair.
## Sorting by string value ensures [code]_make_key(a, b) == _make_key(b, a)[/code].
##
## [ItemValidator] validates item IDs never contain [code]|[/code]. The current naming
## convention (lowercase letters, digits, and underscores only) makes a collision impossible.
## [ItemRegistry] validates that there are no duplicate IDs.
## This convention never changes.
func _make_key(id_a: StringName, id_b: StringName) -> String:
	var a: String = String(id_a)
	var b: String = String(id_b)
	if a <= b:
		return a + "|" + b
	return b + "|" + a


## Validates drop-action exclusivity for a single recipe ingredient.
##
## A recipe ingredient must not be stackable or a [constant ItemData.Type.WEAPON_UPGRADE].
## If it were, dropping it on a matching item could satisfy two outcomes simultaneously
## (combine + stack, or combine + upgrade), creating unresolvable ambiguity.
## Crashes via [method Utils.require] on the first violation.
func _validate_ingredient(data: ItemData) -> void:
	Utils.require(
		data.stack_size == ItemSchema.MIN_STACK,
		(
			(
				"RecipeDefinitions: ingredient '%s' is stackable"
				+ " — recipe ingredients must not be stackable"
			)
			% data.id
		)
	)
	Utils.require(
		data.type != ItemData.Type.WEAPON_UPGRADE,
		(
			(
				"RecipeDefinitions: ingredient '%s' is a WEAPON_UPGRADE"
				+ " — recipe ingredients must not be weapon upgrades"
			)
			% data.id
		)
	)


## Validates the structure and item IDs of a single recipe [Dictionary].
## Returns [code][id_a, id_b, result_id][/code] as [StringName] values for the caller to use.
## Crashes via [method Utils.require] on the first violation.
# Not static: calls ItemRegistry (an autoload), which is not accessible from a static context.
func _validate_recipe(recipe: Dictionary) -> Array[StringName]:
	var ingredients: Variant = recipe.get("ingredients", null)
	Utils.require(
		ingredients is Array and (ingredients as Array).size() == 2,
		"RecipeDefinitions: each recipe must have exactly 2 ingredients"
	)

	var arr: Array = ingredients as Array
	# Ingredients must be plain String literals — not StringName (&"id") — or this check fails.
	Utils.require(
		arr[0] is String and not (arr[0] as String).is_empty(),
		(
			"RecipeDefinitions: ingredient must be a non-empty String (got %s)"
			% type_string(typeof(arr[0]))
		)
	)

	Utils.require(
		arr[1] is String and not (arr[1] as String).is_empty(),
		(
			"RecipeDefinitions: ingredient must be a non-empty String (got %s)"
			% type_string(typeof(arr[1]))
		)
	)

	var result_raw: Variant = recipe.get("result", null)
	Utils.require(
		result_raw is String and not (result_raw as String).is_empty(),
		(
			"RecipeDefinitions: result must be a non-empty String (got %s)"
			% type_string(typeof(result_raw))
		)
	)

	var id_a: StringName = StringName(arr[0] as String)
	var id_b: StringName = StringName(arr[1] as String)
	var result_id: StringName = StringName(result_raw as String)

	var data_a: ItemData = ItemRegistry.get_item_or_crash(id_a)
	var data_b: ItemData = ItemRegistry.get_item_or_crash(id_b)
	var data_result: ItemData = ItemRegistry.get_item_or_crash(result_id)

	_validate_ingredient(data_a)
	_validate_ingredient(data_b)
	# data_result is not validated as an ingredient — the result item may be stackable or a
	# WEAPON_UPGRADE. Drop-action exclusivity only constrains items that can be dropped onto others.

	Utils.require(
		(
			data_a.inventory_size == data_b.inventory_size
			and data_a.inventory_size == data_result.inventory_size
		),
		(
			(
				"RecipeDefinitions: all items in a recipe must share inventory_size"
				+ " — '%s' is %s, '%s' is %s, result '%s' is %s"
			)
			% [
				data_a.id,
				data_a.inventory_size,
				data_b.id,
				data_b.inventory_size,
				data_result.id,
				data_result.inventory_size
			]
		)
	)

	var result: Array[StringName] = [id_a, id_b, result_id]
	return result
