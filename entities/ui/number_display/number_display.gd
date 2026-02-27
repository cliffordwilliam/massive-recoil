class_name NumberDisplay
extends Node2D

@export var rtl: bool = false
@export var pad: bool = false
@export var nums: int = 6


func _ready() -> void:
	for i in range(nums):
		add_child(preload("uid://d0b0oqbpc3v0b").instantiate().init(-(nums - i) if rtl else i))


func display_number(n: int) -> void:
	for d in get_children():
		d.frame = int((str(n).lpad(nums, "0") if rtl else str(n).rpad(nums, "0"))[d.get_index()])
		d.visible = d.get_index() >= (nums - len(str(n))) if rtl else d.get_index() < len(str(n))
		d.visible = true if pad else d.visible
