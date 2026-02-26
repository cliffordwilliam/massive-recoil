class_name Loot
extends RigidBody2D

var id: String


func init(given_id: String, pos: Vector2) -> Loot:
	id = given_id
	$AnimatedSprite.play(id)
	position = pos
	linear_velocity = Vector2.UP.rotated(randf_range(-PI / 4, PI / 4)) * randf_range(100.0, 150.0)
	return self


func _on_area_2d_body_entered(_player: Node2D) -> void:
	match id:
		"money":
			GameState.add_money()
		"handgun", "rifle":
			GameState.pick_up_weapon(id)
	queue_free()
