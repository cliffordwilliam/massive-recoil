# UpgradeItemData
# Configuration resource for UpgradeList items.
#
# Think of this like a sprite sheet resource:
# - You create multiple .tres instances (handgun damage upgrade 1, handgun damage upgrade 2, etc.)
# - UpgradeList holds references to these resources.
#
# This resource contains static definition data only.
# Only meant to be set once via GUI when you instance tres and be left alone forever.
# It should not be mutated at runtime.
class_name UpgradeItemData
extends Resource

# Only meant to be set once via GUI when you instance tres and be left alone forever.
@export var value: float
@export var cost: int
