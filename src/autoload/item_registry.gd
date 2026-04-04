# ItemRegistry
extends Node
## Static catalog of all [ItemData] definitions.

var _items: Dictionary[StringName, ItemData] = {}
var _all: Array[ItemData] = []


func _ready() -> void:
	for i: ItemData in [
		preload("uid://c01y5d8m85ab0"),
		preload("uid://b36gx4cx8i36c"),
		preload("uid://bnp8sq57vc0bf"),
		preload("uid://cede5rosrc5pj"),
		preload("uid://c7mdcqxfnn2ti"),
		preload("uid://cdg8iswh1wxd1"),
		preload("uid://bt75dgxrfeqjo"),
		preload("uid://batle01gbr6m"),
		preload("uid://p18nealyq3gy"),
		preload("uid://4jkjkecupkds"),
		preload("uid://hxvxunwickvv"),
		preload("uid://bsraxoqbw80cg"),
		preload("uid://h6ngoex6t38a"),
		preload("uid://moxj1rp26lkl"),
		preload("uid://1p8xtet0ix4f"),
		preload("uid://cupd3eq1qpwfx"),
		preload("uid://2von02lr0f3t"),
	]:
		_items[i.id] = i
		_all.append(i)


func get_all_items() -> Array[ItemData]:
	return _all


## Returns the [ItemData] for [param id], or [code]null[/code] if not found.
func get_item(id: StringName) -> ItemData:
	return _items.get(id)
