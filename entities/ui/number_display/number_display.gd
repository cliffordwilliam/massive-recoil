class_name NumberDisplay
extends Node2D

@export var rtl: bool = false # Left to right numbering e.g. 00035
@export var pad: bool = false
@export var nums: int = 6


func _ready() -> void:
	for i in range(nums):
		add_child(preload("uid://d0b0oqbpc3v0b").instantiate().init(-(nums - i) if rtl else i))


func display_number(n: int) -> void:
	var text: String = str(n).lpad(nums, "0") if rtl else str(n).rpad(nums, "0")
	var digit_count: int = len(str(n))
	for d in get_children():
		var i: int = d.get_index()
		d.frame = int(text[i])
		d.visible = pad or (i >= (nums - digit_count) if rtl else i < digit_count)
