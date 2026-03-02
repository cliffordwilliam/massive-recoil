class_name WoodenCrate
extends Area2D

const BROKEN_WOODEN_CRATE_FRAME: int = 1

var is_destroyed: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer


func ouch() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	collision_layer = 0
	collision_mask = 0
	sprite_2d.frame = BROKEN_WOODEN_CRATE_FRAME
	Spawner.spawn_money(sprite_2d.global_position)
	timer.start()


func _on_timer_timeout() -> void: # Connected via engine GUI
	queue_free()
