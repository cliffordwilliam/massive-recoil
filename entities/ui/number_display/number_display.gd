class_name NumberDisplay
extends Node2D

@export var right_aligned: bool = false
@export var pad: bool = false
@export var nums: int = 6


func _ready() -> void:
	for i in range(nums):
		add_child(
			preload("uid://d0b0oqbpc3v0b").instantiate().init(-(nums - i) if right_aligned else i),
		)


func display_number(n: int) -> void:
	n = abs(n) # This game never renders negative number
	var text: String = str(n).lpad(nums, "0") if right_aligned else str(n).rpad(nums, "0")
	var digit_count: int = len(str(n))
	for d in get_children():
		var i: int = d.get_index()
		d.frame = int(text[i])
		d.visible = pad or (i >= (nums - digit_count) if right_aligned else i < digit_count)
