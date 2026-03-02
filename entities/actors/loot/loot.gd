class_name Loot
extends RigidBody2D

var id: StringName
var is_collected: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func initialize(given_id: StringName, pos: Vector2) -> void:
	assert(is_node_ready(), "Loot: initialize() must be called after add_child()")
	id = given_id
	global_position = pos
	linear_velocity = Vector2.UP.rotated(randf_range(-PI / 4, PI / 4)) * randf_range(100.0, 150.0)
	animated_sprite_2d.play(id)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body is Player:
		is_collected = true
		if id == "money":
			GameState.add_one_to_money()
		elif GameState.weapon_exists(id):
			GameState.pick_up_a_weapon_by_id(id)
		queue_free()
