extends Area2D


func ouch() -> void:
	if $CollisionShape2D.disabled:
		return
	if $CollisionShape2D.disabled:
		return
	$CollisionShape2D.disabled = true
	$Sprite2D.frame = 1
	get_tree().current_scene.add_child(
		preload("uid://cgcf4l0byw3ur").instantiate().init(
			"money",
			$Sprite2D.global_position,
		),
	)
