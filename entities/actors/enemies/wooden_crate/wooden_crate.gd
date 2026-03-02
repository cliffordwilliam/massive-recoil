class_name WoodenCrate
extends Area2D

const BROKEN_WOODEN_CRATE_FRAME: int = 1

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D


func ouch() -> void:
	if collision_shape_2d.disabled:
		return
	collision_shape_2d.disabled = true
	sprite_2d.frame = BROKEN_WOODEN_CRATE_FRAME
	Spawner.spawn_money(sprite_2d.global_position)
	get_tree().create_timer(1.5).timeout.connect(
		func() -> void:
			if is_instance_valid(self):
				queue_free()
	)
