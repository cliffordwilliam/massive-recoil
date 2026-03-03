class_name WoodenCrate
extends BaseEnemy


# Static wooden boxes found around the world to be broken by player to reveal loot
func on_died() -> void:
	Spawner.spawn_money(animated_sprite_2d.global_position)
