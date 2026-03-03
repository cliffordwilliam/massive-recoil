# Static wooden boxes found around the world to be broken by player to reveal loot
class_name WoodenCrate
extends Area2D

const BROKEN_WOODEN_CRATE_FRAME: int = 1

var is_destroyed: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer


# All enemies need ouch func for taking hit logic
func ouch() -> void:
	if is_destroyed:
		return

	is_destroyed = true

	collision_layer = 0
	collision_mask = 0
	sprite_2d.frame = BROKEN_WOODEN_CRATE_FRAME

	Spawner.spawn_money(sprite_2d.global_position)
	timer.start()


# Linger around a bit before disappearing after being destroyed
func _on_timer_timeout() -> void: # Connected via engine GUI
	queue_free()
