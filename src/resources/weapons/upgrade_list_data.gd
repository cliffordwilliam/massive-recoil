# UpgradeListData
# Base Resource template for weapon upgrades.
#
# Think of this like a sprite sheet resource:
# - You create multiple .tres instances (Handgun Upgrades, Rifle Upgrades, etc.)
# - Weapon scenes reference one of these resources.
#
# This resource contains static list definition that get sets in GUI for one time only.
# It also has dynamic index that moves along the list that gets mutated in gameplay.
# Each instances manages its own index state.
#
# Index is hydrated from save data on load, mutated during gameplay,
# and serialized into a separate save file.
class_name UpgradeListData
extends Resource

# Only meant to be set once via GUI when you instance tres and be left alone forever.
@export var items: Array[UpgradeItemData]

# These are meant to be hydrated on load, mutated in gameplay, dumped to disk on save.
var index: int = 0


# API for GameState to use
func get_current() -> UpgradeItemData:
	assert(items.size() > 0, "UpgradeListData: I cannot be empty")

	var clamped: int = clampi(index, 0, items.size() - 1)
	return items[clamped]


func get_value() -> float:
	return get_current().value


func get_cost() -> int:
	return get_current().cost
