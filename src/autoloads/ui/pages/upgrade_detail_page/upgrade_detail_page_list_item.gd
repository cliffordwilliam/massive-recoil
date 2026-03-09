# Shared script for all shop item sprite scenes.
# TODO: The "Buy" and "Upgrade" item should have new tags that is toggled when
# there are new items for sale or new upgrade options. This feature is not here yet.
class_name UpgradeDetailPageListItem
extends ListItem

var index: int = 0
var cost: int = 0

@onready var index_counter: NumberDisplay = $Index
@onready var cost_counter: NumberDisplay = $Cost


func _ready() -> void:
	_assign_children_properties()


func initialize(given_index: int, given_cost: int) -> void:
	# This can be called before or after my _ready() is called.
	index = given_index
	cost = given_cost
	if is_node_ready():
		_assign_children_properties()


func _assign_children_properties() -> void:
	index_counter.display_number(index)
	cost_counter.display_number(cost)
