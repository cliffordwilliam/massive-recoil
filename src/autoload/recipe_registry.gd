# Autoload cannot have class_name, read "res://docs/godot/can_autoload_have_class_name.md"
# This is the RecipeRegistry autoload
extends Node
## Recipe catalog. Provides ingredient-pair → result lookups.
##
## Loads all [CraftingRecipe] resources from [code]res://data/recipes/[/code] at startup
## and builds an order-independent lookup table for the combine system.

## Maps a canonical ingredient-pair key (see [method _make_key]) to a result id.
var _recipes: Dictionary[String, StringName] = {}


func _ready() -> void:
	for i: CraftingRecipe in [
		preload("uid://dyim1576xnwr7"),
		preload("uid://c8df7b6b4ve8o"),
		preload("uid://lw7wxncte2h2"),
	]:
		_recipes[_make_key(i.ingredient_a.id, i.ingredient_b.id)] = i.result.id


## Returns the result item id when combining [param id_a] and [param id_b].
## Returns [code]&""[/code] (falsy) if no recipe exists — callers can use [code]if result:[/code].
## Ingredient order does not matter.
func get_result(id_a: StringName, id_b: StringName) -> StringName:
	return _recipes.get(_make_key(id_a, id_b), &"")


## Returns a canonical, order-independent key for an ingredient pair.
## Sorting lexicographically ensures [code]_make_key(a, b) == _make_key(b, a)[/code].
static func _make_key(id_a: StringName, id_b: StringName) -> String:
	var a: String = String(id_a)
	var b: String = String(id_b)
	if a <= b:
		return a + "|" + b
	return b + "|" + a
