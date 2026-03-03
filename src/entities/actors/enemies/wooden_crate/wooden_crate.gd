# Static wooden boxes found around the world to be broken by player to reveal loot
class_name WoodenCrate
extends BaseEnemy


func on_died() -> void:
	Spawner.spawn_money(animated_sprite_2d.global_position)
