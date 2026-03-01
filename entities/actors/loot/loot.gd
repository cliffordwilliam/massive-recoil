class_name Loot
extends RigidBody2D


func init(id: StringName, pos: Vector2) -> Loot:
	$AnimatedSprite.play(id)
	position = pos
	linear_velocity = Vector2.UP.rotated(randf_range(-PI / 4, PI / 4)) * randf_range(100.0, 150.0)
	return self


func _on_area_2d_body_entered(_player: Node2D) -> void:
	if $AnimatedSprite.animation == "money":
		GameState.add_one_to_money()
	elif $AnimatedSprite.animation in GameState.weapons:
		GameState.pick_up_a_weapon_by_id($AnimatedSprite.animation)
	queue_free()
