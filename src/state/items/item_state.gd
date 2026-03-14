class_name ItemState
extends RefCounted
## Runtime state for a single item instance.
##
## References an [ItemData] resource that defines the item's static data.
##
## Conceptually similar to how a [Sprite2D] node references a [Texture2D] resource:
##
## - [Texture2D] contains immutable image data.
## - [Sprite2D] holds mutable runtime state such as position and visibility.
##
## Likewise:
##
## - [ItemData] defines the static item template.
## - [ItemState] stores mutable gameplay state such as quantity and UI flags.

## Static template describing the item.
##
## Must not be null. Assigning null indicates a logic error
## and will trigger an error through `Utils.require`.
var data: ItemData:
	set(value):
		if Utils.require(value != null, "ItemState: data cannot be null"):
			data = value

## Number of items owned (used for selling and stackables).
var count: int = 0

## Whether the item should display the **NEW** tag.
var is_new: bool = false


func _init(template: ItemData) -> void:
	data = template
