class_name Loot
extends RigidBody2D

var type: String


func init(given_type: String, pos: Vector2) -> void:
	type = given_type
	$AnimatedSprite.play(type)
	position = pos
	linear_velocity = Vector2.UP.rotated(randf_range(-PI / 4, PI / 4)) * randf_range(100.0, 150.0)


func _on_area_2d_body_entered(_body: Node2D) -> void:
	match type:
		"money":
			GameState.money += 1
		"handgun", "rifle":
			GameState.equip(type)
	queue_free()
