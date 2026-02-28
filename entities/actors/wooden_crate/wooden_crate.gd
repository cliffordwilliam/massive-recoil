extends Area2D


func ouch() -> void:
	if $CollisionShape2D.disabled:
		return
	$CollisionShape2D.disabled = true
	$Sprite2D.frame = 1
	Spawner.spawn("uid://cgcf4l0byw3ur", ["money", $Sprite2D.global_position])
