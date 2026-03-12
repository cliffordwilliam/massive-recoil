class_name ShopItemState
extends RefCounted
## Runtime state for a shop item.
##
## This object references a `ShopItemData` resource that describes the
## item's static definition.
##
## Conceptually this is similar to how a `Sprite2D` node references a
## `Texture2D` resource:
##
## - `Texture2D` contains immutable image data.
## - `Sprite2D` holds mutable runtime state such as position and visibility.
##
## In the same way:
##
## - `ShopItemData` defines the static item template.
## - `ShopItemState` stores mutable gameplay state such as quantity,
##   upgrade level, and UI flags.

## Static template describing the item.
var data: ShopItemData

## Number of items owned (used for selling).
var count: int = 0

## Current upgrade level (used for upgradeable items).
var level: int = 0

## Whether the item should display the **NEW** tag.
var is_new: bool = false

## Whether the item is sold out in the shop and if the item should display the **OUT** tag.
var sold_out: bool = false


func _init(template: ShopItemData) -> void:
	data = template
