class_name ItemData
extends Resource
## Base class for all items.
##
## Holds static properties shared by every item.
##
## Each item type is represented by a single resource instance.
## These resources are typically stored in an autoload registry where
## each instance represents a single item definition.
##
## Multiple gameplay instances may reference the same definition.
## For example:
##
## - Consumables (like health potions) may have multiple instances.
## - Weapons are typically unique within a single gameplay session.
##
## Runtime state for each owned item is stored separately.

## Unique identifier used for lookups.
@export var id: StringName

## Display name shown in UI.
@export var display_name: String

## Flavour text shown in the inspection panel.
@export var description: String
