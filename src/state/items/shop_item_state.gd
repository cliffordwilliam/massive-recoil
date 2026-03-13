class_name ShopItemState
extends RefCounted
## Runtime state for a shop item instance.
##
## References a [ShopItemData] resource that defines the item's static data.
##
## Conceptually similar to how a [Sprite2D] node references a [Texture2D] resource:
##
## - [Texture2D] contains immutable image data.
## - [Sprite2D] holds mutable runtime state such as position and visibility.
##
## Likewise:
##
## - [ShopItemData] defines the static item template.
## - [ShopItemState] stores mutable gameplay state such as quantity and UI flags.

## Static template describing the item.
##
## Must not be null. Assigning null indicates a logic error
## and will trigger an error through `Utils.require`.
var data: ShopItemData:
	set(value):
		if Utils.require(value != null, "ShopItemState: data cannot be null"):
			data = value

## Number of items owned (used for selling and ammo stacks).
var count: int = 0

## Whether the item should display the **NEW** tag.
var is_new: bool = false

## Whether the item is sold out and should display the **OUT** tag.
var sold_out: bool = false


func _init(template: ShopItemData) -> void:
	data = template
