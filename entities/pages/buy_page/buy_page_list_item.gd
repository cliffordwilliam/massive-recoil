class_name BuyPageListItem
extends Sprite2D


func set_tag(new: bool, out: bool) -> void:
	$NewTag.visible = new
	$OutTag.visible = out
