class_name NumberDisplay
extends Node2D

const DIGIT_SCENE: PackedScene = preload("uid://d0b0oqbpc3v0b")

@export var right_aligned: bool = false
@export var pad: bool = false
@export var nums: int = 6


func _ready() -> void:
	for i in range(nums):
		var d: Digit = DIGIT_SCENE.instantiate()
		add_child(d)
		d.initialize(-(nums - i) if right_aligned else i)


func display_number(n: int) -> void:
	n = clampi(n, 0, int(pow(10, nums)) - 1)
	var raw: String = str(n)
	var digit_count: int = raw.length()
	var text: String = raw.lpad(nums, "0") if right_aligned else raw.rpad(nums, "0")
	for child in get_children():
		if child is not Digit:
			continue
		var d: Digit = child
		var i: int = d.get_index()
		d.frame = text[i].to_int()
		d.visible = pad or (i >= (nums - digit_count) if right_aligned else i < digit_count)
