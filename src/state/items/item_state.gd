class_name ItemState
extends RefCounted
## Dynamic state for a single item instance.
##
## References an [ItemData] resource that defines the item's static data.
## Created and owned by [code]PlayerInventory[/code], which enforces all business rules.
##
## See: "res://docs/decisions/item_architecture.md"

## Static template describing the item.
var data: ItemData = null

## Grid position of this item's top-left corner in the inventory.
var position: Vector2i = Vector2i(-1, -1)

## Number of stacks this item occupies.
var stack_count: int = 1

## Runtime stat state for weapon items. [code]null[/code] for all non-weapon items.
var weapon_pointer: WeaponPointer = null


func _init(
	p_data: ItemData,
	p_position: Vector2i,
	p_count: int,
	p_weapon_pointer: WeaponPointer = null,
) -> void:
	data = p_data
	position = p_position
	stack_count = p_count
	weapon_pointer = p_weapon_pointer
