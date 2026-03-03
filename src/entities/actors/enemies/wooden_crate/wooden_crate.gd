# Static wooden boxes found around the world for the player to break and reveal loot.
class_name WoodenCrate
extends BaseEnemy


func on_died() -> void:
	Spawner.spawn_money(animated_sprite_2d.global_position)
