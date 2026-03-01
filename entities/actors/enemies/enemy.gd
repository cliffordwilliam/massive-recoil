class_name Enemy
extends Node

# Deliberate choice so that kids can use _ready normally to reduce cognitive load
@onready var is_added_to_enemy_group: bool = _add_to_enemy_group()


func ouch() -> void:
	pass


func _add_to_enemy_group() -> bool:
	add_to_group("enemies")
	return true
