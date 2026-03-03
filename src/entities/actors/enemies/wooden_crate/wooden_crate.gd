# Static wooden boxes found around the world to be broken by player to reveal loot
class_name WoodenCrate
extends BaseEnemy


# Auto plays the alive animation via GUI
# All wooden crate boxes are 1 hit kill
# TODO: Export to reveal different loot like ammo, etc. Right now its only money
func ouch() -> void:
	if is_dead:
		return

	is_dead = true

	collision_layer = 0
	collision_mask = 0

	Spawner.spawn_money(animated_sprite_2d.global_position)
