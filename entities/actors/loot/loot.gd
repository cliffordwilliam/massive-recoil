class_name Loot
extends RigidBody2D

var id: StringName

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if id:
		animated_sprite_2d.play(id)


func init(given_id: StringName, pos: Vector2) -> Loot:
	id = given_id
	position = pos
	linear_velocity = Vector2.UP.rotated(randf_range(-PI / 4, PI / 4)) * randf_range(100.0, 150.0)
	return self


func _on_area_2d_body_entered(node: Node) -> void: # TODO: Make this one shot
	if node is Player:
		if id == "money":
			GameState.add_one_to_money()
			queue_free()
		elif GameState.weapon_exists(id):
			GameState.pick_up_a_weapon_by_id(id)
			queue_free()
