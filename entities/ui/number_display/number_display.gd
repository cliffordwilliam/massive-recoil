class_name NumberDisplay
extends Node2D

@export var left: bool = false
@export var pad: bool = false
@export var digits: int = 6


func _ready() -> void:
	for i in range(digits):
		var index: int = -i if left else i
		add_child(preload("uid://d0b0oqbpc3v0b").instantiate().init(index))


func display_number(n: int) -> void:
	var s: String = str(n).lpad(digits, "0") if left else str(n).rpad(digits, "0")
	for i in range(digits):
		var digit: Digit = get_node(NodePath(str((digits - 1) - i if left else i)))
		digit.frame = int(s[i])
		digit.visible = i >= (digits - str(n).length()) if left else i < str(n).length()
		digit.visible = true if pad else digit.visible
