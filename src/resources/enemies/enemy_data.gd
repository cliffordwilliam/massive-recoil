# EnemyData
# Configuration resource for enemy variants.
#
# Think of this like a sprite sheet resource:
# - You create multiple .tres instances (weak zombie stats, normal zombie stats, etc.)
# - Enemy scenes reference one of these resources.
#
# This resource contains static definition data only.
# Only meant to be set once via GUI when you instance tres and be left alone forever.
# It should not be mutated at runtime.
#
# To understand how resources work, please read this: res://docs/decisions/how_weapon_works.md
class_name EnemyData
extends Resource

# Only meant to be set once via GUI when you instance tres and be left alone forever.
@export var max_health: float
