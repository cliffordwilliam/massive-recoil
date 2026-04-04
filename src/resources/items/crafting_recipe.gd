class_name CraftingRecipe
extends Resource
## A single crafting recipe: two ingredients combined to produce a result.
##
## All three fields are [ItemData] resource references set in the Inspector.
## Ingredient order does not matter — [RecipeRegistry] normalises the pair.

@export var ingredient_a: ItemData
@export var ingredient_b: ItemData
@export var result: ItemData
