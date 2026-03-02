class_name WoodenCrate
extends Area2D

const BROKEN_WOODEN_CRATE_FRAME: int = 1

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer


func ouch() -> void:
	if collision_shape_2d.disabled:
		return
	collision_shape_2d.disabled = true # TODO: Do not do this, think of another way
	sprite_2d.frame = BROKEN_WOODEN_CRATE_FRAME
	Spawner.spawn_money(sprite_2d.global_position)
	timer.start()


func _on_timer_timeout() -> void: # Connected via engine GUI
	queue_free()
