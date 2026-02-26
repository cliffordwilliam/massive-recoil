class_name NumberDisplay
extends Node2D

@export var right_aligned: bool = false
@export var no_pad: bool = false
@export var digits: int = 6


func _ready() -> void:
	for i in digits:
		var d: Sprite2D = preload("uid://d0b0oqbpc3v0b").instantiate()
		d.position.x = ((i - digits) if right_aligned else i) * d.get_rect().size.x
		add_child(d)


func display_number(n: int) -> void:
	var s: String = str(n).lpad(digits, "0")
	for i in get_child_count():
		get_child(i).frame = int(s[i])
		var is_lead: bool = int(s[i]) == 0 and s.left(i + 1).lstrip("0") == ""
		get_child(i).visible = not (no_pad and is_lead) or (n == 0 and i == get_child_count() - 1)
		get_child(i).visible = true if not no_pad else get_child(i).visible
